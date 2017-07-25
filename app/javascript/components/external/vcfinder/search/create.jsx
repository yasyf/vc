import React from 'react';
import { InvestorsPath } from '../constants.js.erb';
import {ffetch, onChangeSet} from '../utils';

export default class SearchCreate extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      investor: null,
    };
  }

  componentDidMount() {
    $(document.body).on('keyup.searchcreate', this.onKeyUp);

    ffetch(InvestorsPath, 'POST', {investor: {query: this.props.query}})
    .then(investor => this.setState({investor, fetched: true}));
  }

  componentWillUnmount() {
    $(document.body).off('keyup.searchcreate', this.onKeyUp);
  }

  onKeyUp = (event) => {
    switch (event.key) {
      case "Escape":
        this.onCancel();
        break;
    }
  };

  onSubmit = (ev) => {
    ffetch(InvestorsPath, 'POST', {investor: this.state.investor})
    .then(investor => this.props.onClose(true, investor));
  };

  onCancel = () => {
    this.props.onClose(false);
  };

  renderTextArea(label, name) {
    let {investor} = this.state;
    return (
      <label>
        {label}:
        {' '}
        <input
          type="text"
          name={name}
          value={_.get(investor, name) || ''}
          onChange={onChangeSet(investor, name, investor => this.setState({investor}))}
        />
      </label>
    );
  }

  renderSubmit() {
    let {first_name, last_name, competitor} = this.state.investor;
    let complete = first_name && last_name && competitor && competitor.name;
    return (
      <div>
        <button type="button" className="button category-button" onClick={this.onSubmit} disabled={!complete}>
          Create
        </button>
        <button type="button" className="button alert hollow category-button" onClick={this.onCancel}>
          Cancel
        </button>
      </div>
    )
  }

  renderForm() {
    if (!this.state.investor) {
      return 'Please wait...';
    }
    return (
      <form>
        {this.renderTextArea('Fund Name', 'competitor.name')}
        {this.renderTextArea('First Name', 'first_name')}
        {this.renderTextArea('Last Name', 'last_name')}
        {this.renderTextArea('Email', 'email')}
        {this.renderSubmit()}
      </form>
    );
  }

  render() {
    return (
      <div>
        <h2>Add New Investor</h2>
        {this.renderForm()}
      </div>
    )
  }
}