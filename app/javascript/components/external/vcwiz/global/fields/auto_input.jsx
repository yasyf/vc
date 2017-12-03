import React from 'react';
import Input from './input';
import Typeahead from '../shared/typeahead';
import Highlighter from 'react-highlight-words';

export default class AutoInput extends Input {
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
    const { value, path, placeholder, onSelect, onChange } = this.props;
    return (
      <div className="saved-auto-input">
        <Typeahead
          initialValue={value}
          path={path}
          getSuggestionValue={this.getSuggestionValue}
          renderSuggestion={this.renderSuggestion}
          placeholder={placeholder}
          onChange={onChange}
          onSelect={onSelect}
        />
      </div>
    );
  }
}