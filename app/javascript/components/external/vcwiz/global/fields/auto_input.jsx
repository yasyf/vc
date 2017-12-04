import React from 'react';
import Input from './input';
import Typeahead from '../shared/typeahead';
import Highlighter from 'react-highlight-words';

export default class AutoInput extends Input {
  onChange = value => {
    const { name, onChange } = this.props;
    if (!onChange) {
      return;
    }
    onChange({[name]: value});
  };

  getSuggestionValue = ({value}) => {
    return value;
  };

  renderSuggestion = ({label}) => {
    const { value } = this.props;
    return (
      <Highlighter
        highlightClassName='highlighter'
        searchWords={[value]}
        textToHighlight={label}
      />
    );
  };

  renderInput() {
    const { value, onChange, ...rest } = this.props;
    return (
      <div className="saved-auto-input">
        <Typeahead
          initialValue={value}
          tetherClassName="saved-auto-input-tether"
          getSuggestionValue={this.getSuggestionValue}
          renderSuggestion={this.renderSuggestion}
          onChange={this.onChange}
          {...rest}
        />
      </div>
    );
  }
}