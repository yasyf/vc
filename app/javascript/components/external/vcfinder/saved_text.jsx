import React from 'react';

export default class SavedText extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      value: this.props.value,
    };
  }

  renderInput() {
    return (
      <input
        type="text"
        placeholder={this.props.placeholder}
        value={this.state.value}
        onChange={this.onChange}
        onBlur={this.onBlur}
      />
    );
  }

  onChange = (event) => {
    let value = event.target.value;
    this.setState({value});
  };

  onBlur = () => {
    if (this.state.value)
      this.props.onChange({[this.props.name]: this.state.value});
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