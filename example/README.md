FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران
GO VEGAN 🌱
==================================


# germany_plate example

A German car plate with the validator switched on, so you can watch it disapprove.

Run it with `flutter run` from this directory, then type `88` somewhere it doesn't
belong. The frame goes red. The keystroke lands anyway.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            child: BlocProvider(
              create: (_) => PlateCardBloc(spec),
              child: PlateCanvas(
                spec: spec,
                validator: const GermanPlateValidator(),
                autoValidate: true, // paints red on an invalid plate; never blocks input
                onChooseCharacter: (alphabet) async => null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

Drop `validator:` and `autoValidate:` and you get the same plate with no opinions.

The `dependency_overrides` block in `pubspec.yaml` resolves the sibling packages from
this checkout. Delete it when you copy this into an app of your own.
