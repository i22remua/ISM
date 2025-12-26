// lib/widgets/real_time_aforo_display.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class RealTimeAforoDisplay extends StatelessWidget {
  final int currentAforo;
  final int maxAforo;

  const RealTimeAforoDisplay({
    Key? key,
    required this.currentAforo,
    required this.maxAforo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = maxAforo == 0 ? 0.0 : (currentAforo / maxAforo);
    
    // Determina el color basado en la ocupación
    Color aforoColor;
    if (percentage > 0.8) {
      aforoColor = Colors.red; // Alto
    } else if (percentage > 0.5) {
      aforoColor = Colors.orange; // Medio
    } else {
      aforoColor = Colors.green; // Bajo
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Indicador de Progreso Circular
              CircularProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                backgroundColor: aforoColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(aforoColor),
                strokeWidth: 10,
              ),
              // 2. Texto Central
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentAforo',
                      style: TextStyle(
                        fontSize: 48, 
                        fontWeight: FontWeight.bold, 
                        color: aforoColor
                      ),
                    ),
                    Text(
                      'de $maxAforo', 
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Ocupación: ${(percentage * 100).toStringAsFixed(1)}%',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}