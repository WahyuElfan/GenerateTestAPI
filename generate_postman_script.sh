#!/bin/bash

# === CONFIG ===
RAW_FILE="raw_response.js"
OUTPUT_FILE="postman_script.js"
PROMPT_FILE="prompt.txt"
LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/generate_history.log"

# === COLOR ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

mkdir -p "$LOG_DIR"

# === LOAD API KEY ===
API_KEY="${API_KEY}"

if [ -z "$API_KEY" ]; then
  if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
    API_KEY="${API_KEY}"
  elif [ -f "$HOME/.bash_profile" ]; then
    source "$HOME/.bash_profile"
    API_KEY="${API_KEY}"
  fi
fi

# === FALLBACK MANUAL INPUT ===
if [ -z "$API_KEY" ]; then
  echo -e "${YELLOW}[WARN]${NC} API Key tidak ditemukan di environment atau file konfigurasi."
  read -p "Masukkan API Key secara manual: " API_KEY

  if [ -n "$API_KEY" ]; then
    echo "export API_KEY=\"$API_KEY\"" >> "$HOME/.profile"
    echo -e "${GREEN}[OK]${NC} API Key disimpan otomatis ke ~/.profile"
    source "$HOME/.profile"
  fi
fi

# === VALIDASI API KEY ===
if [ -z "$API_KEY" ]; then
  echo -e "${RED}[ERROR]${NC} API Key tetap kosong, script dihentikan."
  exit 1
else
  echo -e "${GREEN}[OK]${NC} API Key berhasil dimuat."
fi

# === BACA PROMPT ===
if [ ! -f "$PROMPT_FILE" ]; then
  echo -e "${RED}[ERROR]${NC} File ${PROMPT_FILE} tidak ditemukan."
  exit 1
fi

PROMPT=$(cat "$PROMPT_FILE")

echo -e "${CYAN}[CHECK]${NC} Menganalisis gaya script dari prompt..."
if ! echo "$PROMPT" | grep -qEi "postman|axios|node\.js"; then
  echo -e "${YELLOW}[WARN]${NC} Prompt tidak menyebut gaya script (Postman/Node.js)."
  echo "Pilih gaya script:"
  echo "  1) Postman"
  echo "  2) Node.js"
  echo "  3) Lanjut tanpa perubahan"
  read -p "Masukkan pilihan (1/2/3): " choice

  case "$choice" in
    1)
      PROMPT="${PROMPT}\nGunakan skrip Postman test (pm.test, pm.expect) untuk validasi API."
      STYLE="Postman"
      ;;
    2)
      PROMPT="${PROMPT}\nGunakan skrip Node.js dengan axios untuk panggilan API."
      STYLE="Node.js"
      ;;
    3)
      STYLE="Unknown"
      ;;
    *)
      STYLE="Unknown"
      ;;
  esac

  echo -e "${CYAN}[INFO]${NC} Gaya script dipilih: ${YELLOW}${STYLE}${NC}"
fi

SAFE_PROMPT=$(jq -Rs . <<< "$PROMPT")

# === MODE PREVIEW ===
if [ "$1" == "--no-send" ]; then
  echo -e "${CYAN}[INFO]${NC} Mode aman aktif (tidak mengirim ke API)."
  echo "$PROMPT"
  exit 0
fi

# === KIRIM REQUEST KE GEMINI API ===
TMP_FILE="${OUTPUT_FILE}.tmp"
echo -e "${CYAN}[INFO]${NC} Mengirim request ke Gemini API..."
curl -s -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [
      {
        "role": "user",
        "parts": [
          { "text": '"$SAFE_PROMPT"' }
        ]
      }
    ]
  }' > "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
  echo -e "${RED}[ERROR]${NC} Response kosong, mungkin koneksi gagal."
  exit 1
fi

echo -e "${GREEN}[OK]${NC} Response disimpan sementara di ${TMP_FILE}"

# === EKSTRAK TEKS DARI JSON ===
if command -v jq &> /dev/null; then
  full_text=$(jq -r '.candidates[0].content.parts[0].text' "$TMP_FILE" 2>/dev/null)
else
  echo -e "${YELLOW}[WARN]${NC} jq tidak ditemukan, pakai fallback parsing."
  full_text=$(grep -o '"text":".*"' "$TMP_FILE" | sed 's/"text":"//' | sed 's/"$//' | sed 's/\\n/\n/g' | sed 's/\\"/"/g')
fi

# === HAPUS BLOK MARKDOWN ===
script_content=$(echo "$full_text" | sed -E '/```javascript/,/```/!d; s/^```javascript//; s/^```//; s/```$//' | sed '/^$/d')
if [ -z "$script_content" ]; then
  script_content="$full_text"
fi

echo "$script_content" > "$RAW_FILE"
cp "$RAW_FILE" "$OUTPUT_FILE"

# === CEK GAYA SCRIPT ===
timestamp=$(date +"%Y-%m-%d %H:%M:%S")
if grep -qE "require\(|import |axios|fetch\(|from 'axios'" "$RAW_FILE"; then
  NODE_FILE="raw_response_node.js"
  mv "$RAW_FILE" "$NODE_FILE"

  echo -e "${YELLOW}[INFO]${NC} Script terdeteksi bergaya Node.js (axios/import)."
  echo -e "${CYAN}[INFO]${NC} File dipindahkan ke: ${YELLOW}${NODE_FILE}${NC}"
  echo -e "${CYAN}[HINT]${NC} Gunakan prompt seperti: 'Buatkan skrip Postman untuk API ...' untuk hasil sesuai Postman test script."

  echo "[$timestamp] NODE_MODE | Prompt: $PROMPT" >> "$LOG_FILE"
else
  echo -e "${GREEN}[OK]${NC} Script bergaya Postman, tersimpan di: ${CYAN}${RAW_FILE}${NC}"
  echo "[$timestamp] POSTMAN_MODE | Prompt: $PROMPT" >> "$LOG_FILE"
fi

# === BERSIH-BERSIH DAN LIMIT LOG ===
rm -f "$TMP_FILE"

if [ -f "$LOG_FILE" ]; then
  echo -e "${CYAN}[CLEANUP]${NC} Memangkas log agar hanya menyimpan 100 entri terakhir..."
  tail -n 100 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi

echo -e "${GREEN}[DONE]${NC} Duplikat tersimpan di: ${OUTPUT_FILE}"
echo -e "${CYAN}[LOG]${NC} Riwayat tersimpan di: ${LOG_FILE}"