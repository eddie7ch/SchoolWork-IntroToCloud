const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send("HighTechMed Landing Page V1");
});

const PORT = process.env.PORT || 8080;
app.listen(PORT);
