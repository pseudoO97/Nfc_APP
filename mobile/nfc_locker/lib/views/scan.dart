import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:http/http.dart' as http;

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String _nfcData = '';
  final String baseUrl = 'http://192.168.0.161:5000';

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

          Uint8List payloadBytes = record.payload;

          String payload = utf8.decode(payloadBytes);

          print('Raw payload: $payload');

          var response = await http.post(
            Uri.parse('$baseUrl/send-nfc-data'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'jwt': payload}),
          );

          if (response.statusCode == 200) {
            var responseBody = jsonDecode(response.body);
            setState(() {
              if (responseBody['status'] == 'success') {
                _nfcData = 'Name: ${responseBody['data']['name']}\n'
                    'Email: ${responseBody['data']['email']}\n'
                    'Role: ${responseBody['data']['role']}';
              } else {
                _nfcData = responseBody['message'];
              }
            });
          } else {
            _showErrorDialog('Failed to retrieve data from backend');
          }
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
