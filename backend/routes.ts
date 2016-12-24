import * as log from 'loglevel';
import { RequestHandler, ErrorRequestHandler } from 'express';

import * as recipes from './recipes';
import * as ingredients from './ingredients';

export const ROUTES: { method: 'get' | 'post' | 'all', route: string, handler: RequestHandler | ErrorRequestHandler }[] = [{
  method: 'get',
  route: '/',
  handler: (req, res, next) => {
    res.render('app', { defaultRecipeIds: recipes.getDefaultRecipeIds() });
  }
}, {
  method: 'get',
  route: '/ingredients',
  handler: (req, res, next) => {
    res.json({
      ingredients: ingredients.getIngredients(),
      groups: ingredients.getGroups()
    });
  }
}, {
  method: 'post',
  route: '/recipes/bulk',
  handler: (req, res, next) => {
    res.json(recipes.bulkLoad(req.body.recipeIds));
  }
}, {
  method: 'get',
  route: '/recipe/:recipeId',
  handler: (req, res, next) => {
    res.render('recipe', { recipe: recipes.load(req.params.recipeId) });
  }
}, {
  method: 'post',
  route: '/recipe',
  handler: (req, res, next) => {
    const recipe = req.body;
    // This is actually already passed, but it's a string, and that seems bad,
    // so we might as well just set it unconditionally here.
    recipe.isCustom = true;
    res.json({ ackRecipeId: recipes.save(recipe) });
  }
}, {
  method: 'all',
  route: '*',
  handler(error, req, res, next) {
    if (error) {
      log.error(error);
      res.status(500);
      if (req.get('Content-Type') === 'application/json') {
        res.send();
      } else {
        res.render('fail-whale');
      }
    } else {
      next();
    }
  }
}, {
  method: 'all',
  route: '*',
  handler(req, res, next) {
    res.status(404);
    if (req.get('Content-Type') === 'application/json') {
      res.send();
    } else {
      res.render('fail-whale');
    }
  }
}];

