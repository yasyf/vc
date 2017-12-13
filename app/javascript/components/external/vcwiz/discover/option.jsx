import React from 'react';
import classNames from 'classnames';

const OptionFactory = (selected) =>
  class Option extends React.Component {
    onChange = event => {
      event.preventDefault();
      event.stopPropagation();
      this.props.onSelect(this.props.option, event);
    };

    onFocus = event => {
      if (!this.props.isFocused) {
        this.props.onFocus(this.props.option, event);
      }
    };

    render() {
      const { isFocused, children, option } = this.props;
      return (
        <div
          className={classNames("filter-option", {'is-focused': isFocused})}
          onFocus={this.onFocus}
          onMouseEnter={this.onFocus}
          onMouseDown={this.onFocus}
          onMouseMove={this.onFocus}
        >
          <div className="value" onClick={this.onChange}>{children}</div>
          <div className="checkbox">
            <input type="checkbox" checked={_.some(selected, {value: option.value})} onChange={this.onChange} />
          </div>
        </div>
      );
    }
  }
;

export default OptionFactory;