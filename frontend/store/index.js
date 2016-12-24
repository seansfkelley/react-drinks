const redux = require('redux');

const rootReducer = redux.combineReducers({
  ui             : require('./reducers/ui'),
  filters        : require('./reducers/filters'),
  ingredients    : require('./reducers/ingredients'),
  recipes        : require('./reducers/recipes'),
  editableRecipe : require('./reducers/editableRecipe')
});

const createStore = redux.applyMiddleware(require('redux-thunk'))(redux.createStore);

module.exports = createStore(rootReducer);
