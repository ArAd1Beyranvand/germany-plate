FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the thoughtful people of Germany to view examples:

https://platexample.ir/#/discover/germany:kotlin

# germany_plate

Germany's licence plates for the plate_core library — the country panel, the car spec with its EU stickers, and the German plate validator.

## Languages

| Language | Folder | Example |
| --- | --- | --- |
| Flutter / Dart | [`flutter/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/flutter) | [platexample](https://platexample.ir/#/discover/germany:flutter) |
| Kotlin | [`kotlin/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/kotlin) | [platexample](https://platexample.ir/#/discover/germany:kotlin) |
| Python | [`python/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/python) | [platexample](https://platexample.ir/#/discover/germany:python) |
| TypeScript | [`typescript/`](https://github.com/ArAd1Beyranvand/germany-plate/tree/main/typescript) | [platexample](https://platexample.ir/#/discover/germany:typescript) |

## Quick start

### Install (Kotlin)

Copy `kotlin/src/commonMain/kotlin/plates/countries/germany/` into `plate_core/kotlin/src/commonMain/kotlin/plates/countries/`.

Then run the tests from `plate_core/kotlin/`: `./gradlew jvmTest`.

### Use

```kotlin
import plates.countries.germany.country

val spec = country.specs["de.car"]
println(country.pkg)
```

## Specs

The specs are the same in every language (they come from shared data).

- `de.car`
- `de.car.1-1-1`
- `de.car.2-2-2`
- `de.car.3-2-3`
- `de.car.2-2-4`
- `de.car.green`
- `de.car.historic.2-2-2`
- `de.car.electric.3-2-2`
- `de.car.seasonal`
- `de.dealer`
- `de.collector`
- `de.shortterm`
- `de.export`
- `de.bundeswehr`

## Themes

- none

## Change it

- Specs: `country.specs`, by id.
- Themes: `country.themes`.
- Validators: `country.validators` (`GermanPlateValidator`, `GermanSerialPlateValidator`, `GermanDatedPlateValidator`, `GermanBundeswehrValidator`).

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/germany-plate/blob/main/LICENSE).
