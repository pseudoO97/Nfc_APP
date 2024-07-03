import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String _nfcData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan NFC Card'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', width: 300, height: 300),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                print('Starting NFC scan...');
                await _scanNFC();
              },
              child: Text('Scan NFC Card'),
            ),
            SizedBox(height: 20),
            Text(
              _nfcData,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      _showErrorDialog('NFC is not available on this device');
      return;
    }

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        print('NFC tag discovered...');
        if (tag.data.containsKey('ndef')) {
          var ndef = Ndef.from(tag);
          if (ndef == null || ndef.cachedMessage == null) {
            _showErrorDialog('NDEF message not found');
            return;
          }

          NdefMessage message = ndef.cachedMessage!;
          NdefRecord record = message.records.first;
          String payload = utf8.decode(record.payload);
          setState(() {
            _nfcData = _parsePayload(payload);
          });
        } else {
          _showErrorDialog('NDEF data not available on this tag');
        }
      } catch (e) {
        _showErrorDialog('Error reading NFC: $e');
      } finally {
        print('NFC session stopped.');
        NfcManager.instance.stopSession();
      }
    });
  }

  String _parsePayload(String payload) {
    try {
      String jwtPayload = payload.substring(3);
      String decodedPayload =
          utf8.decode(base64Url.decode(base64Url.normalize(jwtPayload)));
      Map<String, dynamic> jsonPayload = jsonDecode(decodedPayload);

      return '''
Name: ${jsonPayload['name']}
Email: ${jsonPayload['email']}
iat: ${DateTime.fromMillisecondsSinceEpoch(jsonPayload['iat'] * 1000)}
exp: ${DateTime.fromMillisecondsSinceEpoch(jsonPayload['exp'] * 1000)}
Role: ${jsonPayload['role']}
''';
    } catch (e) {
      print('Error parsing JWT payload: $e');
      return 'Error parsing payload';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
