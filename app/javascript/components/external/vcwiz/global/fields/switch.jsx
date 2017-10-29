import React from 'react';
import Input from './input';

export default class Switch extends Input {
  static defaultProps = {
    type: 'checkbox',
    yesLabel: 'Yes',
    noLabel: 'No',
  };

  onClick = () => {
    this.setState({value: !this.state.value});
    this.props.onChange({[this.props.name]: !this.state.value});
  };

  onChange = _.noop;
  onBlur = _.noop;

  renderInput() {
    let {onBlur, yesLabel, noLabel, label, ...rest} = this.inputProps();
    let checked = !!this.state.value;
    return (
      <div>
        <h6>{label}</h6>
        <div className="switch">
          <input
            className="switch-input"
            checked={checked}
            {...rest}
          />
          <label className="switch-paddle" htmlFor={this.props.name} onClick={this.onClick}>
            <span className={`switch-${checked ? 'active' : 'inactive'}`}>
              {checked ? yesLabel : noLabel}
            </span>
          </label>
        </div>
      </div>
    );
  }
}