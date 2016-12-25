import commonInit from '../common-init';
import * as React from 'react';
import * as ReactDOM from 'react-dom';

import StandaloneRecipe from './StandaloneRecipe';

commonInit();

const APP_ROOT = document.querySelector('#app-root');

// TODO: Redirect to nonexistent error page if this is mangled.
ReactDOM.render(<StandaloneRecipe recipe={(window as any).recipeData} />, APP_ROOT);
