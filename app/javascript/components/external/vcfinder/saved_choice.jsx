import React from 'react';
import Select from 'react-select';
import SavedText from './saved_text';

export default class SavedChoice extends SavedText {
  onChange = (option) => {
    let value;
    if (Array.isArray(option)) {
      value = _.map(option, 'value').join(',');
    } else {
      value = option.value;
    }

    this.setState({value});
    this.props.onChange({[this.props.name]: value});
  };

  onBlur = (option) => {
    // noop
  };

  renderReadonly() {
    let values = this.props.value;
    if (!values) {
      return 'Unknown';
    }
    return values.map(value => _.find(this.props.options, {value}).label).join(', ');
  }

  renderInput() {
    return (
      <Select joinValues={true} clearable={false} {...this.inputProps()} />
    );
  }
}