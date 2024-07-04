import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState("Please present your NFC card.");
  const [isScanning, setIsScanning] = useState(false);

  const handleNFCScan = async () => {
    setIsScanning(true);
    setMessage("Waiting for NFC data...");

    try {
      const response = await fetch('http://localhost:5000/get-nfc-data');
      const data = await response.json();
      
      if (data && data.nfcContent) {
        setMessage(`NFC Data: ${data.nfcContent}`);
      } else {
        setMessage("No NFC data received. Please try again.");
      }
    } catch (error) {
      setMessage(`Error: ${error.message}`);
    } finally {
      setIsScanning(false);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>NFC Authentication</h1>
        <p>{message}</p>
        <button onClick={handleNFCScan} disabled={isScanning}>
          {isScanning ? "Scanning..." : "Scan NFC"}
        </button>
      </header>
    </div>
  );
}

export default App;
