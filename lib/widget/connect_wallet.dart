import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:solana_mobile_client/solana_mobile_client.dart';

class ConnectWalletComponent extends StatefulWidget {
  @override
  _ConnectWalletComponentState createState() => _ConnectWalletComponentState();
}

class _ConnectWalletComponentState extends State<ConnectWalletComponent> {
  bool _isLoading = false;
  MobileWalletAdapterClient? _client;
  AuthorizationResult? result;

  Future<void> _authorize() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final session = await LocalAssociationScenario.create();
      session.startActivityForResult(null);

      _client = await session.start();
      await _doAuthorize(_client!);
      await session.close();
    } catch (e) {
      // Handle error
      print('Authorization error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _doAuthorize(MobileWalletAdapterClient client) async {
    try {
      final result = await client.authorize(
        identityUri: Uri.parse('https://solana.com'),
        iconUri: Uri.parse('favicon.ico'),
        identityName: 'Solana',
        cluster: 'devnet',
      );
      setState(() {
        this.result = result;
      });

      // Handle authorization result
      print('Authorization result: $result');
    } catch (e) {
      // Handle error
      print('Authorization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _authorize,
      child: _isLoading
          ? CircularProgressIndicator()
          : Text('Connect Wallet: ${result?.publicKey ?? 'None'}'),
    );
  }
}
