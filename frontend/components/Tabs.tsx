import * as React from 'react';
import * as classNames from 'classnames';

interface Props {
  tabs: {
    name: string;
    icon?: string;
  }[];
  initialTabIndex?: number;
  className?: string;
}

interface State {
  currentTabIndex: number;
}

export default class Tabs extends React.PureComponent<Props, State> {
  state: State = {
    currentTabIndex: this.props.initialTabIndex || 0
  };

  render() {
    if (this.props.tabs.length !== React.Children.count(this.props.children)) {
      throw new Error('must have exactly as many children as tabs are defined');
    }

    return (
      <div className={classNames('tabs', this.props.className)}>
        <div className='tab-list'>
          {this.props.tabs.map((tab, i) => (
            <div
              onClick={() => { this.setState({ currentTabIndex: i })}}
              className={classNames('tab-button', { 'is-current': i === this.state.currentTabIndex })}
              key={i}
            >
              {tab.name}
            </div>
          ))}
        </div>
        <div className='current-tab'>
          {React.Children.toArray(this.props.children)[this.state.currentTabIndex]}
        </div>
      </div>
    );
  }
}
