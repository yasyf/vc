import React from 'react';
import Input from './input';
import TextArea from './text_area';

export default class PlaceholderInput extends React.Component {
  static defaultProps = {
    multiline: false,
  };

  constructor(props) {
    super(props);

    this.state = {
      focused: false,
      value: this.props.value || '',
    };
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.rowId !== prevProps.rowId) {
      this.setState({value: this.props.value || ''});
    }
    if (this.state.focused && !prevState.focused) {
      this.input.focus();
    }
  }

  onChange = update => {
    this.setState({value: update[this.props.name]});
    this.props.onChange(update);
  };

  onFocus = () => {
    this.setState({focused: true});
  };

  onBlur = () => {
    this.setState({focused: false});
  };

  render() {
    let {onChange, placeholder, multiline, rowId, ...rest} = this.props;
    let showInput = this.state.focused || this.state.value;
    const InputComponent = multiline ? TextArea : Input;
    return (
      <span className="placeholder-input">
        <InputComponent
          className="placeholded"
          wrap={false}
          type=""
          inputRef={input => { this.input = input }}
          value={this.props.value}
          onChange={this.onChange}
          onBlur={this.onBlur}
          style={showInput ? undefined : {display: 'none'}}
          autoComplete="off"
          {...rest}
        />
        <span
          tabIndex={0}
          className="placeholder"
          onClick={this.onFocus}
          onFocus={this.onFocus}
          style={showInput ? {display: 'none'} : undefined}
        >
          {this.props.placeholder}
        </span>
      </span>
    );
  }
}