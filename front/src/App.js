import React, { useState } from 'react';
import './App.css';

function App() {
  const [message, setMessage] = useState("Please present your NFC card.");

  const handleNFCScan = () => {
    if ('NDEFReader' in window) {
      const ndef = new window.NDEFReader();
      ndef.scan().then(() => {
        ndef.onreading = event => {
          const message = event.message;
          for (const record of message.records) {
            const textDecoder = new TextDecoder(record.encoding);
            const recordData = textDecoder.decode(record.data);
            setMessage(`NFC Data: ${recordData}`);
          }
        };
      }).catch(error => {
        setMessage(`NFC Scan failed: ${error}`);
      });
    } else {
      setMessage("NFC not supported on this browser.");
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>NFC Authentication</h1>
        <p>{message}</p>
        <button onClick={handleNFCScan}>Scan NFC</button>
      </header>
    </div>
  );
}

export default App;
