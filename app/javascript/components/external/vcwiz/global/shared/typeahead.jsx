import React from 'react';
import Autosuggest from 'react-autosuggest';
import Tether from './tether';
import classNames from 'classnames';

export default class Typeahead extends React.Component {
  static defaultProps = {
    querySub: 'QUERY',
    minLength: 3,
    onChange: _.noop,
    onSelect: _.noop,
  };

  constructor(props) {
    super(props);

    this.state = {
      loaded: false,
      suggestions: [],
      value: props.initialValue || '',
    };
  }

  componentDidMount() {
    // eslint-disable-next-line global-require
    const Bloodhound = require('bloodhound-js');
    this.engine = new Bloodhound({
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      datumTokenizer: this.props.dataFields ? Bloodhound.tokenizers.obj.whitespace(...this.props.dataFields) : Bloodhound.tokenizers.whitespace,
      identify: (o) => o.id,
      remote: {
        url: this.props.path,
        wildcard: this.props.querySub,
      }
    });
    this.engine.initialize().then(() => this.setState({loaded: true}));
  }

  onSuggestionsFetchRequested = ({ value }) => {
    let suggestions = [];
    const onResults = results => {
      suggestions = suggestions.concat(results);
      this.setState({suggestions});
    };
    this.engine.search(value, onResults, onResults);
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
    this.props.onChange(newValue);
  };

  renderSuggestionsContainer = ({ containerProps , children, query }) => {
    return (
      <Tether className={classNames('typeahead-tether', this.props.tetherClassName)}>
        <div {...containerProps} ref={containerProps.ref}>{children}</div>
      </Tether>
    );
  };

  render() {
    const { suggestions, value } = this.state;
    const { getSuggestionValue, renderSuggestion, onBlur, placeholder } = this.props;
    return (
      <div className="typeahead">
        <Autosuggest
          suggestions={suggestions}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          getSuggestionValue={getSuggestionValue}
          renderSuggestion={renderSuggestion}
          inputProps={{
            value,
            placeholder,
            onBlur,
            onChange: this.onChange,
          }}
          renderSuggestionsContainer={this.renderSuggestionsContainer}
          onSuggestionSelected={this.onSuggestionSelected}
          shouldRenderSuggestions={this.shouldRenderSuggestions}
        />
      </div>
    );
  }
}