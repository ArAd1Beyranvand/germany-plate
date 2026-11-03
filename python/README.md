FREE PALESTINE 🇮🇷🇵🇸 پاینده ایران

GO VEGAN 🌱

==================================

From the mighty people of Iran to the thoughtful people of Germany to view examples:

https://platexample.ir/#/discover/germany:python

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

### Install (Python)

Copy `python/plates/countries/germany/` into `plate_core/python/plates/countries/`.

Then run the tests from `plate_core/python/`: `pytest`.

### Use

```python
from plates.countries.germany.data import SPECS, THEMES

spec = SPECS["de.car"]
print(spec.id)
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

- Pick a spec: use another key of `SPECS`.
- Pick a theme: use another key of `THEMES`.
- Validators: `VALIDATORS` maps the names `GermanPlateValidator`, `GermanSerialPlateValidator`, `GermanDatedPlateValidator`, `GermanBundeswehrValidator` to classes.

## License

See [LICENSE](https://github.com/ArAd1Beyranvand/germany-plate/blob/main/LICENSE).
