const React      = require('react');
const classnames = require('classnames');

const TitleBar = React.createClass({
  displayName : 'TitleBar',

  propTypes : {
    leftIcon            : React.PropTypes.string,
    children            : React.PropTypes.node,
    rightIcon           : React.PropTypes.string,
    leftIconOnTouchTap  : React.PropTypes.func,
    onTouchTap          : React.PropTypes.func,
    rightIconOnTouchTap : React.PropTypes.func
  },

  render() {
    let leftIcon, rightIcon;
    if (this.props.leftIcon != null) {
      if (this.props.leftIcon.slice(0, 2) === 'fa') {
        leftIcon = React.createElement("i", { 
          "className": (`fa float-left ${this.props.leftIcon}`),  
          "onTouchTap": (this.props.leftIconOnTouchTap)
        });
      } else {
        leftIcon = React.createElement("img", { 
          "src": (this.props.leftIcon),  
          "onTouchTap": (this.props.leftIconOnTouchTap)
        });
      }
    }

    if (this.props.rightIcon != null) {
      if (this.props.rightIcon.slice(0, 2) === 'fa') {
        rightIcon = React.createElement("i", { 
          "className": (`fa float-right ${this.props.rightIcon}`),  
          "onTouchTap": (this.props.rightIconOnTouchTap)
        });
      } else {
        rightIcon = React.createElement("img", { 
          "src": (this.props.rightIcon),  
          "onTouchTap": (this.props.rightIconOnTouchTap)
        });
      }
    }

    const showingIcons = (this.props.leftIcon != null) || (this.props.rightIcon != null);

    if (showingIcons) {
      if (leftIcon == null) {  leftIcon = React.createElement("span", {"className": 'spacer float-left'}, " "); }
      if (rightIcon == null) { rightIcon = React.createElement("span", {"className": 'spacer float-right'}, " "); }
    }

    return React.createElement("div", {"className": (classnames('title-bar', this.props.className))},
      (leftIcon),
      (React.Children.count(this.props.children) > 0 ? React.createElement("div", {"className": (classnames('title', { 'showing-icons' : showingIcons })), "onTouchTap": (this.props.onTouchTap)},
          (this.props.children)
        ) : undefined),
      (rightIcon)
    );
  }
});

module.exports = TitleBar;
