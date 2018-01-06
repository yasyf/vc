import React from 'react';

export default class Input extends React.Component {
  static defaultProps = {
    wrap: true,
    onSubmit: e => e.preventDefault(),
    type: 'text',
    showLabel: false,
    onBlur: _.noop,
    debounced: false,
    managed: false,
  };

  constructor(props) {
    super(props);

    this.state = {
      value: props.value || '',
      valueNonce: props.valueNonce,
      lastValue: null,
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.value && (this.props.managed || nextProps.valueNonce !== this.state.valueNonce)) {
      this.setState({value: nextProps.value, valueNonce: nextProps.valueNonce});
    }
  }

  inputProps() {
    const {wrap, inputRef, formRef, showLabel, debounced, managed, valueNonce, ...rest} = this.props;
    return {
      ...rest,
      onChange: this.onChange,
      onBlur: this.onBlur,
      value: this.state.value,
      ref: inputRef,
    }
  }

  renderInput() {
    return (
      <input key="input" {...this.inputProps()} />
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
    this.setState({value}, () => {
      if (this.props.debounced) {
        this.submit();
      }
    });
    if (!this.props.debounced) {
      this.props.onChange({[this.props.name]: value});
    }
  };

  onBlur = () => {
    if (this.props.debounced) {
      this.submit.flush();
    }
    this.props.onBlur();
  };

  renderInputAndLabel() {
    if (this.props.showLabel) {
      return (
        <label>
          <h6>{this.props.placeholder}</h6>
          {this.renderInput()}
        </label>
      );
    } else {
      return this.renderInput();
    }
  }

  render() {
    if (this.props.wrap) {
      return (
        <form ref={this.props.formRef} onSubmit={this.props.onSubmit}>
          {this.renderInputAndLabel()}
        </form>
      );
    } else {
      return this.renderInputAndLabel();
    }
  }
}