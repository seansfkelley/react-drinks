import { intersection } from 'lodash';
import { assert } from './tinyassert';

export const BASE_URL = 'http://spiritgui.de';
export const BASE_LIQUORS = ['gin', 'vodka', 'whiskey', 'rum', 'brandy', 'tequila', 'wine', 'liqueur'];
export const ANY_BASE_LIQUOR = 'any';
export const UNASSIGNED_BASE_LIQUOR = 'UNASSIGNED';
export const BASE_TITLES_BY_TAG = {
  gin: 'Gin',
  vodka: 'Vodka',
  whiskey: 'Whiskey',
  rum: 'Rum',
  brandy: 'Brandy/Cognac',
  tequila: 'Tequila/Mezcal',
  wine: 'Wine/Champagne',
  liqueur: 'Liqueur/Other'
};

export const BASIC_LIQUOR_TAGS = ['gin', 'vodka', 'whiskey', 'rum', 'brandy', 'tequila', 'wine'];

// TODO: Replace this silly assertion with a fat-enum type that does this automagically.
assert(intersection(Object.keys(BASE_TITLES_BY_TAG), BASE_LIQUORS).length === BASE_LIQUORS.length);

