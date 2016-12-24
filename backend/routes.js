const _   = require('lodash');
const log = require('loglevel');

const recipes     = require('./recipes');
const ingredients = require('./ingredients');

module.exports = [{
  method  : 'get',
  route   : '/',
  handler(req, res) {
    return res.render('app', { defaultRecipeIds : recipes.getDefaultRecipeIds() });
  }
}
, {
  method  : 'get',
  route   : '/ingredients',
  handler(req, res) {
    return res.json({
      ingredients : ingredients.getIngredients(),
      groups      : ingredients.getGroups()
    });
  }
}
, {
  method  : 'post',
  route   : '/recipes/bulk',
  handler(req, res) {
    return res.json(recipes.bulkLoad(req.body.recipeIds));
  }
}
, {
  method  : 'get',
  route   : '/recipe/:recipeId',
  handler(req, res) {
    return res.render('recipe', { recipe : recipes.load(req.params.recipeId) });
  }
}
, {
  method  : 'post',
  route   : '/recipe',
  handler(req, res) {
    const recipe = req.body;
    // This is actually already passed, but it's a string, and that seems bad,
    // so we might as well just set it unconditionally here.
    recipe.isCustom = true;
    return res.json({ ackRecipeId : recipes.save(recipe) });
  }
}
, {
  method  : 'all',
  route   : '*',
  handler(error, req, res, next) {
    if (error) {
      log.error(error);
      res.status(500);
      if (req.get('Content-Type') === 'application/json') {
        return res.send();
      } else {
        return res.render('fail-whale');
      }
    } else {
      return next();
    }
  }
}
, {
  method  : 'all',
  route   : '*',
  handler(req, res, next) {
    res.status(404);
    if (req.get('Content-Type') === 'application/json') {
      return res.send();
    } else {
      return res.render('fail-whale');
    }
  }
}
];
