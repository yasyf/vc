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
    {children}
  </div>
);

export default class Tabs extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      selected: props.defaultIndex || 0,
    };
  }

  onClick = i => e => {
    this.setState({selected: i});
    e.preventDefault();
  };

  renderTabs() {
    const { tabs } = this.props;
    const { selected } = this.state;
    return (
      <div className="tab-list-wrapper">
        <ul className="tab-list" role="tablist">
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