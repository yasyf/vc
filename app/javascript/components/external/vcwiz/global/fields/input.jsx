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
      dirty: false,
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
    if (this.state.dirty) {
      this.props.onChange({[this.props.name]: this.state.value});
      this.setState({dirty: false});
    }
  }, 200, {maxWait: 5000});

  onChange = (event) => {
    let value = event.target.value;
    this.setState({value, dirty: true});
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