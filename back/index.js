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
  const { jwt: nfcData } = req.body;

  if (!nfcData) {
    return res.status(400).json({ error: "No JWT provided" });
  }

  try {
    // Split the JWT into parts and decode the payload
    const [, base64Payload] = nfcData.split(".");
    const decodedPayload = Buffer.from(base64Payload, "base64").toString(
      "utf-8"
    );
    const { email } = JSON.parse(decodedPayload);

    connection.query(
      "SELECT * FROM users WHERE email = ?",
      [email],
      (err, results) => {
        if (err) {
          console.error("Database query error:", err);
          return res.status(500).json({ error: "Database query error" });
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
    res.status(500).json({ error: "Error decoding JWT" });
  }
});

app.listen(5000, "10.13.11.150", () => {
  console.log(`Server running on http://10.13.11.150:5000`);
});
