import React from 'react';

export default class SavedText extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: this.props.value || '',
      dirty: false,
    };
  }

  inputProps() {
    return {
      ...this.props,
      onChange: this.onChange,
      onBlur: this.onBlur,
      value: this.state.value,
    }
  }

  renderInput() {
    return (
      <input
        type="text"
        {...this.inputProps()}
      />
    );
  }

  submit = _.debounce(() => {
    if (this.state.dirty && this.state.value) {
      this.props.onChange({[this.props.name]: this.state.value});
      this.setState({dirty: false});
    }
  }, 500, {maxWait: 5000});

  onChange = (event) => {
    let value = event.target.value;
    this.setState({value, dirty: true});
    this.submit();
  };

  onBlur = () => {
    this.submit.flush();
  };

  render() {
    return (
      <form>
        <label>
          {this.props.label}:
          {this.renderInput()}
        </label>
      </form>
    );
  }
}