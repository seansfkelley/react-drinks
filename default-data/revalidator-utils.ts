import { assign } from 'lodash';
import { inspect } from 'util';
import * as revalidator from 'revalidator';

assign((revalidator.validate as any).defaults, {
  validateFormats: true,
  validateFormatsStrict: true,
  validateFormatExtensions: true,
  additionalProperties: false,
  cast: false
});

export const REQUIRED_STRING = {
  type: 'string',
  required: true
};

export const OPTIONAL_STRING = {
  type: 'string',
  required: false
};

// I wanted to have real types here, but the revalidator types suck.
export function validateOrThrow(object: any, schema: any) {
  const validation = revalidator.validate(object, schema);
  if (!validation.valid) {
    throw new Error(`validation failed: \n${inspect(validation.errors)}`);
  }
}
