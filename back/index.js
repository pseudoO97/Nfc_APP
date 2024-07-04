const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const jwt = require("jsonwebtoken");
const connection = require("./db");

const app = express();
const port = 5000;

app.use(cors());
app.use(bodyParser.json());

app.post("/send-nfc-data", (req, res) => {
  const nfcData = req.body.jwt;
  if (!nfcData) {
    return res.status(400).send("No JWT provided");
  }

  try {
    const base64Url = nfcData.split(".")[1];
    const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
    const decodedPayload = Buffer.from(base64, "base64").toString();
    const decodedNfcData = JSON.parse(decodedPayload);

    const { email } = decodedNfcData;

    connection.query(
      "SELECT * FROM users WHERE email = ?",
      [email],
      (err, results) => {
        if (err) {
          console.error("Database query error:", err);
          res.status(500).send("Database query error");
          return;
        }

        if (results.length > 0) {
          const user = results[0];
          res.json({
            status: "success",
            data: {
              name: user.name,
              email: user.email,
              role: user.role,
            },
          });
        } else {
          res
            .status(404)
            .json({ status: "error", message: "User not allowed" });
        }
      }
    );
  } catch (err) {
    console.error("Error decoding JWT:", err);
    res.status(500).send("Error decoding JWT");
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
