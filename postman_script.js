pm.test("Status code is 204 No Content or 200 OK", function () {
    pm.expect(pm.response.code).to.be.oneOf([204, 200]); // Accept both 204 and 200 for success
});
pm.test("Response time is less than 200ms", function () {
    pm.expect(pm.response.responseTime).to.be.below(200);
});
pm.test("Content-Type is present", function () {
    pm.expect(pm.response.headers.has("Content-Type")).to.be.true;
});
// Validasi tambahan jika response body diharapkan (misalnya jika status 200 OK)
if (pm.response.code === 200) {
    pm.test("Response body is not empty", function () {
        pm.expect(pm.response.text()).to.not.be.empty;
    });
    pm.test("Response body contains success message", function () {
        const responseJson = pm.response.json();
        pm.expect(responseJson).to.have.property("message");
        pm.expect(responseJson.message).to.eql("User deleted successfully"); // Ganti dengan pesan sukses yang sesuai
    });
}
// Negative Test: Cek jika ID tidak valid
pm.test("Negative Test: Check for 404 Not Found when deleting non-existent user", function() {
    pm.environment.set("invalidUserId", "9999"); //Set ID invalid (contoh)
    pm.sendRequest({
        url: pm.environment.get("baseUrl") + "/users/" + pm.environment.get("invalidUserId"), // Gabungkan base URL dan endpoint
        method: 'DELETE'
    }, function (err, response) {
        if (err) {
            pm.expect.fail("Error in negative test: " + err);
        } else {
            pm.expect(response.code).to.eql(404); // Memastikan kode status 404
            const responseJson = response.json();
            pm.expect(responseJson).to.have.property("message");
            pm.expect(responseJson.message).to.eql("User not found"); // Ganti dengan pesan error yang sesuai
        }
    });
});
