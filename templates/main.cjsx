# @cjsx React.DOM

Ingredient = React.createClass {
  render : ->
    <div className='ingredient'>
      <div className='name'>{@props.name}</div>
    </div>
}

IngredientList = React.createClass {
  getInitialState : -> { ingredients : [] }

  componentDidMount : ->
    Promise.resolve $.get(@props.url)
    .then (ingredients) =>
      @setState { ingredients }
    .catch (e) =>
      console.error @props.url, e

  render : ->
    ingredientNodes = @state.ingredients.map (ingredient) ->
      return <Ingredient name={ingredient.display} key={ingredient.tag}/>

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

React.render <IngredientList url='/ingredients' />, $('body')[0]
