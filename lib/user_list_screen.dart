import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List Screen'),
      ),
      body: Center(
        child: Text('Contenido de la pantalla de lista de usuarios'),
      ),
    );
  }
}
