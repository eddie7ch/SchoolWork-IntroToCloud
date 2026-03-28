const express = require('express');
const app = express();

app.get('/appointments', (req, res) => {
    res.json([
        { id: 1, patient: "John Doe", date: "2026-03-20" },
        { id: 2, patient: "Jane Smith", date: "2026-03-22" }
    ]);
});

app.listen(3000);
