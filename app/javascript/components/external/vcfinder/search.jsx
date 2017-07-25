import Handlebars from 'handlebars';
import React from 'react';
import Modal from 'react-modal';
import { InvestorsSearchPath, InvestorsPath } from './constants.js.erb';
import SearchCreate from './search/create';

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

    this.state = {
      modalOpen: false,
      query: null,
    };
  }

  componentDidMount() {
    let typeahead = $('.typeahead');
    typeahead.bind('typeahead:beforeselect', (event, investor) => {
      this.props.onSelect(investor);
      typeahead.typeahead('val', '');
      typeahead.typeahead('close');
      event.preventDefault();
    });

    typeahead.bind('vcwiz:createinvestor', (event, query) => {
      this.setState({modalOpen: true, query: query});
    });

    typeahead.typeahead({
      minLength: 3,
      highlight: true,
    }, {
      source: this.engine,
      templates: {
        suggestion: Handlebars.compile($('#result-template').html()),
        notFound: Handlebars.compile($('#no-result-template').html()),
      },
    });
  }

  onClose = (investor) => {
    this.props.onSelect(investor);
    this.setState({modalOpen: false});
  };

  renderModal() {
    return (
      <Modal
        isOpen={this.state.modalOpen}
        contentLabel="Create New Investor"
      >
        <SearchCreate query={this.state.query} onClose={this.onClose} />
      </Modal>
    );
  }

  renderNav() {
    return (
      <nav className="top-bar">
        <ul className="menu">
          <li>
            <input type="search" placeholder="Find an investor..." className="typeahead top-search-bar" />
          </li>
        </ul>
      </nav>
    );
  }

  render() {
    return (
      <div>
        {this.renderModal()}
        {this.renderNav()}
      </div>
    );
  }
}