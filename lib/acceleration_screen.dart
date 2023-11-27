import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class AccelerationScreen extends StatefulWidget {
  @override
  _AccelerationScreenState createState() => _AccelerationScreenState();
}

class _AccelerationScreenState extends State<AccelerationScreen> {
  double threshold = 9.8 * 2.0; // Umbral para detectar caídas
  double verticalThreshold = 9.0; // Umbral para determinar si está acostado
  bool fallDetected = false;
  bool isLyingDown = false; // Variable para determinar si está acostado
  double accelerationValue = 0.0;
  late DatabaseReference _fallDataRef;
  bool isSavingData = false;

  @override
  void initState() {
    super.initState();
    _fallDataRef = FirebaseDatabase.instance.reference().child('fall_data');
    _initAccelerometer();
  }

  void _initAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) async {
      double x = event.x ?? 0.0;
      double y = event.y ?? 0.0;
      double z = event.z ?? 0.0;

      double accelerationTotal = _calculateTotalAcceleration(x, y, z);

      bool isFall = accelerationTotal > threshold;

      // Verifica si está acostado comparando con el umbral vertical
      bool lyingDown = z < -verticalThreshold || z > verticalThreshold;

      setState(() {
        fallDetected = isFall;
        isLyingDown = lyingDown;
        accelerationValue = accelerationTotal;
      });

      if (fallDetected && !isSavingData) {
        print('¡Caída detectada!');
        await _saveFallDataToFirebase(); // Espera a que se complete antes de continuar
      }
    });
  }

  double _calculateTotalAcceleration(double x, double y, double z) {
    return math.sqrt(x * x + y * y + z * z);
  }

  Future<void> _saveFallDataToFirebase() async {
    setState(() {
      isSavingData = true;
    });

    try {
      // Obtiene la ubicación actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Guarda los datos en Firebase Realtime Database
      await _fallDataRef.push().set({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'acceleration': accelerationValue,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'activity': isLyingDown ? 'Acostado' : 'De Pie', // Agrega la actividad
      });
    } catch (e) {
      print('Error al obtener la ubicación: $e');
    }

    setState(() {
      isSavingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detección de Caídas'),
      ),
      body: Container(
        color: Colors.blue[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: fallDetected ? Colors.red : Colors.green,
                elevation: 5.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    fallDetected ? 'Riesgo de Caída' : 'Estado Normal',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                width: 200.0,
                height: 200.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fallDetected ? Colors.red : Colors.green,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        accelerationValue.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'm/s²',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Aceleración',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        isLyingDown
                            ? 'Acostado'
                            : 'De Pie', // Muestra la actividad
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              if (isSavingData)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
