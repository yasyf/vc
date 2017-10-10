import React from 'react';
import Input from './input';

export default class PlaceholderInput extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      focused: false,
      value: '',
    };
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.focused && !prevState.focused) {
      this.input.focus();
    }
  }

  onChange = ({value}) => {
    this.setState({value});
    this.props.onChange(value);
  };

  onClick = () => {
    this.setState({focused: true});
  };

  onBlur = () => {
    this.setState({focused: false});
  };

  render() {
    let {onChange, placeholder, ...props} = this.props;
    if (this.state.focused || this.state.value) {
      return <Input
        name="value"
        wrap={false}
        type=""
        inputRef={input => { this.input = input }}
        value={this.state.value}
        onChange={this.onChange}
        onBlur={this.onBlur}
        {...props}
      />;
    } else {
      return <span onClick={this.onClick}>{this.props.placeholder}</span>;
    }
  }
}