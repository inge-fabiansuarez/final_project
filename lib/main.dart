import 'package:flutter/material.dart';
import 'acceleration_screen.dart';
import 'location_screen.dart';
import 'user_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Puedes realizar acciones adicionales según sea necesario, como mostrar un mensaje al usuario.
  }

  // El resto del código de tu aplicación
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      /* title: 'Proyecto Final', */
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    AccelerationScreen(),
    LocationScreen(),
    UserListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
        title: Text('Proyecto Final'),
      ), */
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Aceleración',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Ubicación',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Lista de Usuarios',
          ),
        ],
      ),
    );
  }
}
