// Mendapatkan status kode dari respons
let statusCode = pm.response.statusCode;
// Validasi status kode 200 (Berhasil)
if (statusCode === 200) {
    pm.test("Berhasil Menghapus: Status kode adalah 200", () => {
        pm.response.to.have.status(200);
    });
    // Tambahkan validasi tambahan berdasarkan body response jika diperlukan
    // Contoh: Memastikan respons body memiliki properti "message" dengan nilai tertentu
    // pm.expect(pm.response.json().message).to.eql("Data berhasil dihapus");
}
// Validasi status kode 400 (Gagal)
else if (statusCode === 400) {
    pm.test("Gagal Menghapus: Status kode adalah 400", () => {
        pm.response.to.have.status(400);
    });
    // Validasi tambahan untuk respons 400 (sangat penting!)
    // Ini membantu Anda memastikan mengapa permintaan itu gagal
    pm.test("Respons 400 mengandung pesan kesalahan yang spesifik", () => {
        const responseJson = pm.response.json();
        // Periksa apakah respons memiliki properti "error"
        pm.expect(responseJson).to.have.property('error');
        // Contoh: Memastikan pesan kesalahan sesuai dengan yang diharapkan
        // Anda perlu menyesuaikan ini berdasarkan struktur respons API Anda
        pm.expect(responseJson.error).to.be.a('string');
        pm.expect(responseJson.error).to.not.be.empty; // Memastikan pesan kesalahan tidak kosong
        //Contoh lain, cek error detail jika ada
        //if(responseJson.hasOwnProperty('details')){
        //    pm.expect(responseJson.details).to.be.an('array').that.is.not.empty;
        //}
    });
}
//Status kode yang tidak diharapkan
else {
     pm.test("Status code tidak diharapkan: " + statusCode, () => {
        pm.expect.fail("Status code " + statusCode + " tidak sesuai dengan yang diharapkan (200 atau 400).");
    });
}
pm.test("Berhasil Menghapus: Pesan sukses diterima", () => {
    pm.expect(pm.response.json().message).to.eql("Data berhasil dihapus");
});
pm.test("Gagal Menghapus: Pesan kesalahan spesifik diterima", () => {
    const responseJson = pm.response.json();
    pm.expect(responseJson.error).to.eql("ID tidak valid");
    pm.expect(responseJson.code).to.eql(123); // contoh kode error
});
