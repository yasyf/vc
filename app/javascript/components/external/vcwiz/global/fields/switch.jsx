import React from 'react';
import Input from './input';
import classNames from 'classnames';

export default class Switch extends Input {
  static defaultProps = {
    type: 'checkbox',
    yesLabel: 'Yes',
    noLabel: 'No',
    highlight: false,
    managed: true,
  };

  onClick = () => {
    this.setState({value: !this.state.value});
    this.props.onChange({[this.props.name]: !this.state.value});
  };

  onChange = _.noop;
  onBlur = _.noop;

  renderInput() {
    let {onBlur, yesLabel, noLabel, label, description, highlight, ...rest} = this.inputProps();
    let checked = !!this.state.value;
    return (
      <div>
        <h6>{label}</h6> {description}
        <div className="switch">
          <input
            className="switch-input"
            checked={checked}
            {...rest}
          />
          <label
            className={classNames('switch-paddle', {'glow-highlight': highlight && !checked})}
            htmlFor={this.props.name}
            onClick={this.onClick}
          >
            <span className={`switch-${checked ? 'active' : 'inactive'}`}>
              {checked ? yesLabel : noLabel}
            </span>
          </label>
        </div>
      </div>
    );
  }
}