# @cjsx React.DOM

Test = React.createClass {
  render : ->
    <div>herro</div>
}


React.renderComponent <Test/>, $('body')[0]
