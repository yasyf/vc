import React from 'react';
import classNames from 'classnames';

const Tab = ({ children, selected, onClick }) => (
  <li
    className={classNames('tab', {'tab-active': selected})}
    role="tab"
    aria-selected={selected}
    aria-disabled="false"
    onClick={onClick}
    tabIndex={selected ? 0 : undefined}
  >
    {children}
  </li>
);

const Panel = ({ children, selected }) => (
  <div
    className={classNames('tab-panel', {'tab-panel-active': selected})}
    role="tabpanel"
  >
    {selected ? children : null}
  </div>
);

export default class Tabs extends React.Component {
  static defaultProps = {
    onTabChange: _.noop,
    scrollShadows: false,
  };

  constructor(props) {
    super(props);

    this.state = {
      selected: props.defaultIndex || 0,
    };
  }

  componentDidMount() {
    this.props.onTabChange(this.state.selected);
  }

  onClick = i => e => {
    this.setState({selected: i});
    this.props.onTabChange(i);
    e.preventDefault();
  };

  renderTabs() {
    const { tabs, scrollShadows } = this.props;
    const { selected } = this.state;
    return (
      <div className="tab-list-wrapper">
        <ul className={classNames('tab-list', {'horizontal-scroll-shadow': scrollShadows})} role="tablist">
          {tabs.map((t, i) =>
            <Tab key={i} onClick={this.onClick(i)} selected={i === selected}>{t}</Tab>
          )}
        </ul>
      </div>
    );
  }

  renderPanels() {
    const { panels } = this.props;
    const { selected } = this.state;
    return (
      <div className="tab-panel-wrapper">
        {panels.map((p, i) => <Panel key={i} selected={i === selected}>{p}</Panel>)}
      </div>
    );
  }

  render() {
    const { page } = this.props;
    return (
      <div className="tabs-component">
        {this.renderTabs()}
        {this.renderPanels()}
      </div>
    );
  }
}