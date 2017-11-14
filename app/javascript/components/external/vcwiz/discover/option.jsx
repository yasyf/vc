import React from 'react';

const OptionFactory = (selected) =>
  class Option extends React.Component {
    onChange = event => {
      this.props.onSelect(this.props.option, event);
    };

    render() {
      const { children, option } = this.props;
      return (
        <div className="filter-option">
          <div className="value">{children}</div>
          <div className="checkbox">
            <input type="checkbox" checked={_.some(selected, option)} onChange={this.onChange} />
          </div>
        </div>
      );
    }
  }
;

export default OptionFactory;