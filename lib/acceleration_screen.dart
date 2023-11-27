import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:math' as math;

class AccelerationScreen extends StatefulWidget {
  @override
  _AccelerationScreenState createState() => _AccelerationScreenState();
}

class _AccelerationScreenState extends State<AccelerationScreen> {
  double threshold = 9.8 * 2.0; // Umbral para detectar caídas
  bool fallDetected = false;
  double accelerationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // Lee los valores de aceleración en los ejes x, y, y z
      double x = event.x ?? 0.0;
      double y = event.y ?? 0.0;
      double z = event.z ?? 0.0;

      // Calcula la aceleración total
      double accelerationTotal = _calculateTotalAcceleration(x, y, z);

      // Compara con el umbral para detectar caídas
      bool isFall = accelerationTotal > threshold;

      setState(() {
        fallDetected = isFall;
        accelerationValue = accelerationTotal;
      });

      if (fallDetected) {
        // Aquí puedes realizar acciones adicionales cuando se detecta una caída
        print('¡Caída detectada!');
        _saveFallDataToFirebase(); // Guardar en Firebase al detectar una caída
      }
    });
  }

  double _calculateTotalAcceleration(double x, double y, double z) {
    // Calcula la aceleración total utilizando la fórmula matemática
    return math.sqrt(x * x + y * y + z * z);
  }

  void _saveFallDataToFirebase() {
    // Lógica para guardar datos en Firebase
    // Implementa la lógica de Firebase aquí
    print('Guardando datos en Firebase...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detección de Caídas'),
      ),
      body: Container(
        color: Colors.blue[900], // Establecer el color de fondo a azul oscuro
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
