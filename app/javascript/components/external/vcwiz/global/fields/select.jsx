import React from 'react';
import ReactSelect from 'react-select-plus';
import Input from './input';

export default class Select extends Input {
  onChange = (option) => {
    this.setState({value: option});
    this.props.onChange({[this.props.name]: option});
  };

  onBlur = (option) => {
    // noop
  };

  renderInput() {
    let Component = this.props.loadOptions ? ReactSelect.Async : ReactSelect;
    return (
      <Component joinValues={true} clearable={false} {...this.inputProps()} />
    );
  }
}