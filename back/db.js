// db.js
const mysql = require("mysql2");

// Create a connection using the provided credentials
const connection = mysql.createConnection({
  host: "viaduct.proxy.rlwy.net",
  user: "root",
  password: "louHWjzobPJyuXHQcyCUdFFvuQjYOAOO",
  database: "railway",
  port: 30162,
  connectTimeout: 10000,
});

// Connect to the database
connection.connect((err) => {
  if (err) {
    console.error("Error connecting to the database:", err.stack);
    return;
  }
  console.log("Connected to the database as id " + connection.threadId);
});

module.exports = connection;
