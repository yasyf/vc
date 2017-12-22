import React from 'react';
import {extend} from '../utils';
import AutoInput from '../fields/auto_input';
import Input from '../fields/input';
import TextArea from '../fields/text_area';
import Filter from '../../discover/filter';

export default class SettingsBase extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      dirty: {},
      inputs: {},
    };
  }

  onChange = name => (update, cb) => {
    const value = update[name];
    const data = extend(this.state.data, _.set({}, name, value));
    const dirty = extend(this.state.dirty, {[name]: true});
    this.setState({data, dirty}, cb);
  };

  onBlurDirty = name => {
    if (!this.state.dirty[name]) {
      return;
    }
    const value = _.get(this.state.data, name);
    const dirty = extend(this.state.dirty, {[name]: false});
    this.setState({dirty});
    return _.set({}, name, value || null);
  };

  onInputChange = name => value => {
    const inputs = extend(this.state.inputs, {[name]: value});
    this.setState({inputs});
  };

  inputProps(name, placeholder) {
    return {
      key: name,
      name: name,
      value: _.get(this.state.data, name),
      placeholder: placeholder,
      showLabel: true,
      wrap: false,
      onBlur: this.onBlur(name),
      onChange: this.onChange(name),
    };
  }

  renderAutoInput(name, placeholder, path) {
    return <AutoInput {...this.inputProps(name, placeholder)} path={path} />;
  }

  renderInput(name, placeholder) {
    return <Input {...this.inputProps(name, placeholder)} />;
  }

  renderTextArea(name, placeholder) {
    return <TextArea {...this.inputProps(name, placeholder)} />;
  }

  renderFilter(name, label, optionProps) {
    return (
      <Filter
        key={name}
        name={name}
        label={label}
        input={this.state.inputs[name]}
        value={this.state.data[name]}
        showLabel={true}
        showSelected={4}
        onInputChange={this.onInputChange(name)}
        onChange={update => this.onChange(name)(update, this.onBlur(name))}
        {...optionProps}
      />
    );
  }
}