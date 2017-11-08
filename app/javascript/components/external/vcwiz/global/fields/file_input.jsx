import React from 'react';
import Input from './input';
import {timestamp} from '../utils';

export default class FileInput extends Input {
  static defaultProps = {
    ...Input.defaultProps,
    showLabel: true,
    placeholder: 'Select File',
  };

  onChange = (event) => {
    let value = event.target.value;
    this.setState({value});
    this.props.onChange({[this.props.name]: event.target.files[0]});
  };

  componentWillMount() {
    this.setState({inputId: timestamp().toString()});
  }

  inputProps() {
    return {
      ...super.inputProps(),
      type: 'file',
      className: this.props.showLabel ? 'show-for-sr': undefined,
      id: this.state.inputId,
    };
  }

  renderInputAndLabel() {
    const { showLabel, placeholder } = this.props;
    const { value } = this.state;
    if (showLabel) {
      return [
        <label key="label" htmlFor={this.state.inputId} className="button">
          {value ? _.last(value.split('\\')) : placeholder}
        </label>,
        this.renderInput()
      ];
    } else {
      return this.renderInput();
    }
  }
}