# @cjsx React.DOM

Ingredient = React.createClass {
  render : ->
    <div className='ingredient'>
      <div className='name'>{@props.name}</div>
    </div>
}

IngredientList = React.createClass {
  render : ->
    ingredientNodes = @props.ingredients.map (ingredient) ->
      return <Ingredient name={ingredient.name} key={ingredient.name}/>

    <div className='ingredient-list'>
      {ingredientNodes}
    </div>
}

ingredients = [
  name : 'a'
,
  name : 'b'
,
  name : 'c'
]

React.render <IngredientList ingredients={ingredients} />, $('body')[0]
