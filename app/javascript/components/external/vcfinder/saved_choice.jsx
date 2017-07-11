import React from 'react';
import Select from 'react-select';
import SavedText from './saved_text';

export default class SavedChoice extends SavedText {
  onChange = (option) => {
    if (Array.isArray(option)) {
      this.props.onChange({[this.props.name]: _.map(option, 'value').join(',')});
    } else {
      this.props.onChange({[this.props.name]: option.value});
    }
  };

  renderInput() {
    return (
      <Select
        {...this.props}
        onChange={this.onChange}
      />
    );
  }
}