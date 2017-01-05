import * as log from 'loglevel';
import { RequestHandler, ErrorRequestHandler, Request, Response, NextFunction } from 'express';

import { DbRecipe } from '../shared/types';
import * as Constants from '../shared/constants';
import * as recipes from './recipes';
import * as ingredients from './ingredients';

export const ROUTES: { method: 'get' | 'post' | 'all', route: string, handler: RequestHandler | ErrorRequestHandler }[] = [{
  method: 'get',
  route: '/',
  handler: (_req: Request, res: Response, _next: NextFunction) => {
    res.render('app', { defaultRecipeIds: recipes.getDefaultRecipeIds(), Constants });
  }
}, {
  method: 'get',
  route: '/ingredients',
  handler: (_req: Request, res: Response, _next: NextFunction) => {
    res.json(ingredients.getIngredients());
  }
}, {
  method: 'post',
  route: '/recipes/bulk',
  handler: (req: Request, res: Response, _next: NextFunction) => {
    res.json(recipes.bulkLoad(req.body.recipeIds));
  }
}, {
  method: 'get',
  route: '/recipe/:recipeId',
  handler: (req: Request, res: Response, _next: NextFunction) => {
    res.render('recipe', { recipe: recipes.load(req.params.recipeId), Constants });
  }
}, {
  method: 'post',
  route: '/recipe',
  handler: (req: Request, res: Response, _next: NextFunction) => {
    const recipe: DbRecipe = req.body;
    // This is actually already passed, but it's a string, and that seems bad,
    // so we might as well just set it unconditionally here.
    recipe.isCustom = true;
    res.json({ ackRecipeId: recipes.save(recipe) });
  }
}, {
  method: 'all',
  route: '*',
  handler: (error: any, req: Request, res: Response, next: NextFunction) => {
    if (error) {
      log.error(error);
      res.status(500);
      if (req.get('Content-Type') === 'application/json') {
        res.send();
      } else {
        res.render('fail-whale', { Constants });
      }
    } else {
      next();
    }
  }
}, {
  method: 'all',
  route: '*',
  handler(req: Request, res: Response, _next: NextFunction) {
    res.status(404);
    if (req.get('Content-Type') === 'application/json') {
      res.send();
    } else {
      res.render('fail-whale', { Constants });
    }
  }
}];

