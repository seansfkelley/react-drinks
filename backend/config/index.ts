import * as log from 'loglevel';
import { readFileSync } from 'fs';
import { safeLoad} from 'js-yaml';

interface Config {
  couchDb: {
    url: string;
    recipeDbName: string;
    configDbName: string;
    ingredientDbName: string;
  };
}

let filename;
switch (process.env.NODE_ENV) {
  case 'production':
    log.info('loading config from config-production.yaml');
    filename = 'config-production.yaml';
    break;
  case 'staging':
    log.info('loading config from config-staging.yaml');
    filename = 'config-staging.yaml';
    break;
  default:
    log.info('loading config from config-development.yaml');
    filename = 'config-development.yaml';
}

export default safeLoad(readFileSync(`${__dirname}/${filename}`).toString()) as Config;
