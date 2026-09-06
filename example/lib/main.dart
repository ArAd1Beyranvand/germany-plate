import 'package:flutter/material.dart';
import 'package:core_plate/core_plate.dart';
import 'package:germany_plate/germany_plate.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    const spec = GermanPlates.car;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PlateCanvas(
              spec: spec,
              validator: const GermanPlateValidator(),
              autoValidate:
                  true, // paints red on an invalid plate; never blocks input
              onChooseCharacter: (alphabet) async => null,
            ),
          ),
        ),
      ),
    );
  }
}
