import React from 'react';
import Select from 'react-select';
import SavedText from './saved_text';
import classNames from 'classnames';

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
    let {value, highlight} = this.props;
    highlight = highlight || [];

    if (!value) {
      return 'Unknown';
    } else if (!Array.isArray(value)) {
      value = [value];
    }
    return value.map(value => {
      let label = _.find(this.props.options, {value}).label;
      let found = highlight.indexOf(value) !== -1;
      return <span className={classNames('badge', {'success': found})} key={value}>{label}</span>;
    });
  }

  renderInput() {
    return (
      <Select joinValues={true} clearable={false} {...this.inputProps()} />
    );
  }
}