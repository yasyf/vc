import React from 'react';

export default class Input extends React.Component {
  static defaultProps = {
    wrap: true,
    type: 'text',
    onBlur: _.noop,
  };

  constructor(props) {
    super(props);

    this.state = {
      value: this.props.value || '',
      lastValue: null,
    };
  }

  componentWillReceiveProps(nextProps) {
    if (!this.state.value && nextProps.value !== this.props.value) {
      this.setState({value: nextProps.value});
    }
  }

  inputProps() {
    const {wrap, inputRef, formRef, ...props} = this.props;
    return {
      ...props,
      onChange: this.onChange,
      onBlur: this.onBlur,
      value: this.state.value,
      ref: inputRef,
    }
  }

  renderInput() {
    return (
      <input {...this.inputProps()} />
    );
  }

  submit = _.debounce(() => {
    if (this.state.lastValue !== this.state.value) {
      this.props.onChange({[this.props.name]: this.state.value});
      this.setState({lastValue: this.state.value});
    }
  }, 150, {maxWait: 5000});

  onChange = (event) => {
    let value = event.target.value;
    this.setState({value});
    this.submit();
  };

  onBlur = () => {
    this.submit.flush();
    this.props.onBlur();
  };

  render() {
    if (this.props.wrap) {
      return (
        <form ref={this.props.formRef}>
          {this.renderInput()}
        </form>
      );
    } else {
      return this.renderInput();
    }
  }
}