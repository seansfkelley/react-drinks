import { invert, pickBy } from 'lodash';
import { DisplayIngredient } from '../shared/types';

const ASCII_TO_ENTITY: { [fraction: string]: string } = {
  '1/4' : '\u00bc',
  '1/2' : '\u00bd',
  '3/4' : '\u00be',
  '1/8' : '\u215b',
  '3/8' : '\u215c',
  '5/8' : '\u215d',
  '7/8' : '\u215e',
  '1/3' : '\u2153',
  '2/3' : '\u2154'
};

const ENTITY_TO_ASCII: { [entity: string]: string } = invert(ASCII_TO_ENTITY) as any;

const ASCII_FRACTION_REGEX = new RegExp(Object.keys(ASCII_TO_ENTITY).join('|'), 'g');
const ENTITY_FRACTION_REGEX = new RegExp(Object.keys(ENTITY_TO_ASCII).join('|'), 'g');

export function fractionify(s?: string) {
  return s != null ? s.replace(ASCII_FRACTION_REGEX, (m) => ASCII_TO_ENTITY[m]) : undefined;
}

export function defractionify(s?: string) {
  return s != null ? s.replace(ENTITY_FRACTION_REGEX, (m) => ENTITY_TO_ASCII[m]) : undefined;
}

// This does not account for fractionified strings!
const MEASURE_AMOUNT_REGEX = /^(\d[- \/\d]*)(.*)$/;

export interface UnitWithMeasure {
  unit: string;
  measure?: string;
}

export function splitMeasure(s?: string): UnitWithMeasure {
  if (s != null) {
    const normalizedString = s.trim();
    const match = MEASURE_AMOUNT_REGEX.exec(normalizedString);
    return match
      ? { measure: match[1].trim(), unit: match[2].trim() }
      : { unit: normalizedString }
  } else {
    return { unit: '' };
  }
}

const COUNT_REGEX = /^[-. \/\d]+/;

const MEASUREMENTS = [
  'ml',
  'cl',
  'l',
  'liter',
  'oz',
  'ounce',
  'pint',
  'part',
  'shot',
  'tsp',
  'teaspoon',
  'tbsp',
  'tablespoon',
  'cup',
  'bottle',
  'barspoon',
  'dash',
  'dashes',
  'drop',
  'pinch',
  'pinches',
  'slice'
];

export function parseIngredientFromText(rawText: string): DisplayIngredient {
  let displayAmount: string | undefined;
  let displayUnit: string | undefined;
  let displayIngredient: string;

  let workingText = rawText.trim();
  const match = COUNT_REGEX.exec(workingText);
  if (match) {
    const displayAmount = match[0];
    workingText = workingText.slice(displayAmount.length).trim();
  }

  const possibleUnit = workingText.split(' ')[0];
  if (MEASUREMENTS.indexOf(possibleUnit) !== -1 || MEASUREMENTS.some(m => possibleUnit === `${m}s`)) {
    displayUnit = possibleUnit;
    workingText = workingText.slice(displayUnit.length).trim();
  }

  displayIngredient = workingText;

  return pickBy({ displayAmount, displayUnit, displayIngredient }) as DisplayIngredient;
};
