import Handlebars from 'handlebars';
import React from 'react';
import { InvestorsSearchPath } from './constants.js.erb';

export default class Search extends React.Component {
  constructor(props) {
    super(props);

    this.engine = new Bloodhound({
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name', 'firm'),
      identify: (o) => o.id,
      remote: {
        url: InvestorsSearchPath,
        wildcard: 'QUERY',
      }
    });
  }

  componentDidMount() {
    let typeahead = $('.typeahead');
    typeahead.bind('typeahead:beforeselect', (event, investor) => {
      this.props.onSelect(investor);
      typeahead.typeahead('val', '');
      typeahead.typeahead('close');
      event.preventDefault();
    });
    typeahead.typeahead({
      minLength: 3,
      highlight: true,
    }, {
      source: this.engine,
      templates: {
        suggestion: Handlebars.compile($('#result-template').html()),
      },
    });
  }

  render() {
    return (
        <nav className="top-bar">
          <ul className="menu">
            <li>
              <input type="search" placeholder="Search" className="typeahead top-search-bar" />
            </li>
          </ul>
        </nav>
    );
  }
}