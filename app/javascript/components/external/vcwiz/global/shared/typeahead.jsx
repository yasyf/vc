import React from 'react';
import Bloodhound from 'bloodhound-js';
import Autosuggest from 'react-autosuggest';

export default class Typeahead extends React.Component {
  static defaultProps = {
    querySub: 'QUERY',
    minLength: 3,
  };

  constructor(props) {
    super(props);

    this.state = {
      loaded: false,
      suggestions: [],
      value: '',
    };

    this.engine = new Bloodhound({
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace(...this.props.dataFields),
      identify: (o) => o.id,
      remote: {
        url: this.props.path,
        wildcard: this.props.querySub,
      }
    });
  }

  componentDidMount() {
    this.engine.initialize().then(() => this.setState({loaded: true}));
  }

  onSuggestionsFetchRequested = ({ value }) => {
    const sync = suggestions => this.setState({suggestions});
    const async = suggestions => this.setState({suggestions: this.state.suggestions.concat(suggestions)});
    this.engine.search(value, sync, async);
  };

  onSuggestionsClearRequested = () => {
    this.setState({suggestions: []});
  };

  onSuggestionSelected = (event, { suggestion }) => {
    this.props.onSelect(suggestion);
  };

  shouldRenderSuggestions = value => value.trim().length >= this.props.minLength;

  onChange = (event, { newValue }) => {
    this.setState({value: newValue});
  };

  render() {
    return (
      <div className="typeahead">
        <Autosuggest
          suggestions={this.state.suggestions}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          getSuggestionValue={this.props.getSuggestionValue}
          renderSuggestion={this.props.renderSuggestion}
          inputProps={{
            value: this.state.value,
            onChange: this.onChange,
            placeholder: this.props.placeholder,
          }}
          onSuggestionSelected={this.onSuggestionSelected}
          shouldRenderSuggestions={this.shouldRenderSuggestions}
        />
      </div>
    );
  }
}