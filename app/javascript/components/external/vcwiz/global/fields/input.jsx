import React from 'react';

export default class Input extends React.Component {
  static defaultProps = {
    wrap: true,
    type: 'text',
  };

  constructor(props) {
    super(props);

    this.state = {
      value: this.props.value || '',
      lastValue: null,
    };
  }

  inputProps() {
    const {wrap, inputRef, ...props} = this.props;
    return {
      ...props,
      onChange: this.onChange,
      onBlur: this.onBlur,
      value: this.state.value,
    }
  }

  renderInput() {
    return (
      <input
        ref={this.props.inputRef}
        type={this.props.type}
        {...this.inputProps()}
      />
    );
  }

  submit = _.debounce(() => {
    if (this.state.lastValue !== this.state.value) {
      this.props.onChange({[this.props.name]: this.state.value});
      this.setState({lastValue: this.state.value});
    }
  }, 300, {maxWait: 5000});

  onChange = (event) => {
    let value = event.target.value;
    this.setState({value});
    this.submit();
  };

  onBlur = () => {
    this.submit.flush();
  };

  render() {
    if (this.props.wrap) {
      return (
        <form>
          {this.renderInput()}
        </form>
      );
    } else {
      return this.renderInput();
    }
  }
}