const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

let nfcData = null;

app.post('/send-nfc-data', (req, res) => {
  nfcData = req.body;
  res.sendStatus(200);
});

app.get('/get-nfc-data', (req, res) => {
  res.json(nfcData);
  nfcData = null; // Clear data after sending
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
