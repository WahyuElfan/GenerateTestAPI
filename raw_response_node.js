const express = require('express');
const app = express();
const port = 3000;
app.use(express.json()); // Middleware untuk parsing body JSON
// Simulasi database (ganti dengan database yang sebenarnya)
const items = {
    1: { name: 'Item 1' },
    2: { name: 'Item 2' },
};
// Middleware otentikasi (sederhana)
const otentikasiDiperlukan = (req, res, next) => {
    const apiKey = req.headers['x-api-key'];
    if (apiKey !== 'secret_key') { // Ganti dengan logika otentikasi yang sebenarnya
        return res.status(401).json({ message: 'Autentikasi gagal' });
    }
    next(); // Lanjutkan ke handler berikutnya
};
app.delete('/items/:itemId', otentikasiDiperlukan, (req, res) => {
    const itemId = parseInt(req.params.itemId); // Konversi ke integer
    // 1. Validasi Input (ID)
    if (isNaN(itemId)) {
        return res.status(400).json({ message: 'ID Item tidak valid' });
    }
    // 2. Validasi Keberadaan Sumber Daya
    if (!items[itemId]) {
        return res.status(404).json({ message: 'Item tidak ditemukan' });
    }
    // 3. Otorisasi (Contoh: Hanya admin yang bisa menghapus - disimulasikan)
    const userRole = req.headers['x-user-role'];
    if (userRole !== 'admin') {
        return res.status(403).json({ message: 'Tidak diizinkan menghapus item' });
    }
    // 4. Penghapusan (Jika validasi berhasil)
    delete items[itemId];
    return res.status(200).json({ message: 'Item berhasil dihapus' });
});
app.listen(port, () => {
    console.log(`Server berjalan di http://localhost:${port}`);
});
