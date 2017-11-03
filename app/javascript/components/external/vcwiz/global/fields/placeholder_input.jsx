import React from 'react';
import Input from './input';

export default class PlaceholderInput extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      focused: false,
      value: this.props.value || '',
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
    let {onChange, placeholder, ...rest} = this.props;
    let showInput = this.state.focused || this.state.value;
    return (
      <span>
        <Input
          name="value"
          className="placeholded"
          wrap={false}
          type=""
          inputRef={input => { this.input = input }}
          value={this.state.value}
          onChange={this.onChange}
          onBlur={this.onBlur}
          style={showInput ? undefined : {display: 'none'}}
          {...rest}
        />
        <span
          className="placeholder"
          onClick={this.onClick}
          style={showInput ? {display: 'none'} : undefined}
        >
          {this.props.placeholder}
        </span>
      </span>
    );
  }
}