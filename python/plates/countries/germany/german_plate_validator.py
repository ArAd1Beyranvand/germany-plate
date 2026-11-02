"""Port of germany_plate/lib/src/german_plate_validator.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

import re
from dataclasses import dataclass

from plates.core.validators.plate_validator import (
    GatedPlateValidator, PlateEntry, PlateValidation, is_digits, is_digits_of_length)

_FORBIDDEN_LETTER_PAIRS = frozenset(('SS', 'SA', 'KZ', 'HJ', 'NS', 'AH', 'HH', 'SD', 'IS'))
_FORBIDDEN_NUMBERS = frozenset(('88', '18', '14'))

# The area code may carry an umlaut; the identifier may not (an umlaut there marks a fictitious plate).
_DISTRICT = re.compile(r'[A-ZÄÖÜ]{1,3}')
_IDENTIFIER_LETTERS = re.compile(r'[A-Z]{1,2}')

# (letters, min digits, max digits) of the issued identifier shapes.
_IDENTIFIER_SHAPES = ((1, 1, 3), (2, 1, 2), (2, 3, 3), (1, 4, 4), (2, 4, 4))


def _district_and_serial_error(district: str, serial: str) -> PlateValidation | None:
    if not _DISTRICT.fullmatch(district):
        return PlateValidation.invalid('District code must be 1-3 letters.')
    if not is_digits(serial):
        return PlateValidation.invalid('The number must be digits.')
    return None


def _opens_with(prefix: str, serial: str) -> bool:
    return prefix.startswith(serial[:2])


@dataclass(frozen=True)
class GermanPlateValidator(GatedPlateValidator):
    gate_group = 'letters'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        registration = self.validate_fields(entry.group('district'), entry.group('letters'), entry.group('serial'))
        if not registration.is_valid:
            return registration
        return self.validate_season(entry.group('seasonStart'), entry.group('seasonEnd'))

    @staticmethod
    def validate_season(start: str, end: str) -> PlateValidation:
        for month in (start, end):
            if len(month) < 2:
                continue
            if not is_digits_of_length(month, 2):
                return PlateValidation.invalid('A season month is two digits.')
            if not 1 <= int(month) <= 12:
                return PlateValidation.invalid(f'"{month}" is not a month.')
        return PlateValidation.valid()

    @staticmethod
    def validate_fields(district: str, identifier_letters: str, identifier_digits: str) -> PlateValidation:
        d, letters, digits = district.upper(), identifier_letters.upper(), identifier_digits
        if not _DISTRICT.fullmatch(d):
            return PlateValidation.invalid('District code must be 1-3 letters.')
        if not _IDENTIFIER_LETTERS.fullmatch(letters):
            return PlateValidation.invalid('Identifier letters must be 1-2 letters.')
        if digits and not (is_digits(digits) and len(digits) <= 4):
            return PlateValidation.invalid('Identifier digits must be 1-4 digits.')
        if digits.startswith('0'):
            return PlateValidation.invalid('The serial cannot start with 0.')
        if len(d) + len(letters) + len(digits) > 8:
            return PlateValidation.invalid('Plate exceeds the 8-character maximum.')
        if digits and not any(n == len(letters) and lo <= len(digits) <= hi for n, lo, hi in _IDENTIFIER_SHAPES):
            return PlateValidation.invalid(
                f'{len(letters)} letter(s) and {len(digits)} digit(s) is not an issued identifier shape.')
        if letters in _FORBIDDEN_LETTER_PAIRS:
            return PlateValidation.invalid(f'"{letters}" is a forbidden combination.')
        if len(d) == 1 and len(letters) == 1 and d + letters in _FORBIDDEN_LETTER_PAIRS:
            return PlateValidation.invalid(f'"{d}{letters}" is a forbidden combination.')
        if digits and digits in _FORBIDDEN_NUMBERS:
            return PlateValidation.invalid(f'"{digits}" is a forbidden combination.')
        return PlateValidation.valid()


@dataclass(frozen=True)
class GermanSerialPlateValidator(GatedPlateValidator):
    """`06` dealer or `07` collector; the vectors and VALIDATORS build it bare, so the prefix follows the spec."""

    prefix: str | None = None
    gate_group = 'serial'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        prefix = self.prefix or ('07' if entry.spec.id == 'de.collector' else '06')
        district, serial = entry.group('district').upper(), entry.group('serial')
        error = _district_and_serial_error(district, serial)
        if error:
            return error
        if not _opens_with(prefix, serial):
            return PlateValidation.invalid(f'This number begins "{prefix}".')
        if len(serial) > 5:
            return PlateValidation.invalid('The number is five digits.')
        return PlateValidation.valid()


_DAYS_IN_MONTH = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)


@dataclass(frozen=True)
class GermanDatedPlateValidator(GatedPlateValidator):
    """`04` short-term (serial opens `04`) or export (no reserved opening); built bare, so the spec decides."""

    prefix: str | None = None
    gate_group = 'expiryDay'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        prefix = self.prefix or ('04' if entry.spec.id == 'de.shortterm' else None)
        district, serial = entry.group('district').upper(), entry.group('serial')
        error = _district_and_serial_error(district, serial)
        if error:
            return error
        if prefix is not None and not _opens_with(prefix, serial):
            return PlateValidation.invalid(f'This number begins "{prefix}".')
        if len(serial) > 5:
            return PlateValidation.invalid('The number is five digits.')
        return self.validate_expiry(entry.group('expiryDay'), entry.group('expiryMonth'), entry.group('expiryYear'))

    @staticmethod
    def validate_expiry(day: str, month: str, year: str) -> PlateValidation:
        for name, value in (('day', day), ('month', month), ('year', year)):
            if len(value) >= 2 and not is_digits_of_length(value, 2):
                return PlateValidation.invalid(f'The expiry {name} is two digits.')
        day_ok = len(day) == 2 and is_digits(day)
        if len(month) == 2 and is_digits(month):
            m = int(month)
            if not 1 <= m <= 12:
                return PlateValidation.invalid(f'"{month}" is not a month.')
            if day_ok and not 1 <= int(day) <= _DAYS_IN_MONTH[m - 1]:
                return PlateValidation.invalid(f'"{day}" is not a day of month {month}.')
        elif day_ok and not 1 <= int(day) <= 31:
            return PlateValidation.invalid(f'"{day}" is not a day.')
        return PlateValidation.valid()


@dataclass(frozen=True)
class GermanBundeswehrValidator(GatedPlateValidator):
    gate_group = 'serialTail'

    def judge(self, entry: PlateEntry) -> PlateValidation:
        if entry.group('district').upper() != 'Y':
            return PlateValidation.invalid('A Bundeswehr plate begins "Y".')
        serial = entry.group('serial') + entry.group('serialTail')
        if not is_digits(serial):
            return PlateValidation.invalid('The number must be digits.')
        if len(serial) > 6:
            return PlateValidation.invalid('The number is six digits.')
        return PlateValidation.valid()
