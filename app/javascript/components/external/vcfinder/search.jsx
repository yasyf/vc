import Handlebars from 'handlebars';
import React from 'react';
import Modal from 'react-modal';
import { InvestorsFuzzySearchPath, InvestorsPath } from './constants.js.erb';
import SearchCreate from './search/create';
import Investor from './investor';

Modal.defaultStyles.overlay.zIndex = 1000;

export default class Search extends React.Component {
  constructor(props) {
    super(props);

    this.engine = new Bloodhound({
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name', 'firm'),
      identify: (o) => o.id,
      remote: {
        url: InvestorsFuzzySearchPath,
        wildcard: 'QUERY',
      }
    });

    this.state = {
      modalOpen: false,
      investor: null,
    };
  }

  componentDidMount() {
    this.typeahead = $('.typeahead');
    let typeahead = this.typeahead;

    typeahead.bind('typeahead:beforeselect', (event, investor) => {
      this.onOpen(investor);
      typeahead.typeahead('val', '');
      typeahead.typeahead('close');
      event.preventDefault();
    });

    typeahead.bind('vcwiz:createinvestor', (event, query) => {
      this.onOpen(query);
    });

    typeahead.typeahead({
      minLength: 3,
      highlight: true,
    }, {
      limit: 5,
      source: this.engine,
      templates: {
        suggestion: Handlebars.compile($('#result-template').html()),
        notFound: Handlebars.compile($('#no-result-template').html()),
      },
    });
  }

  onOpen = (investor) => {
    this.setState({modalOpen: true, investor});
  };

  onClose = (success, investor) => {
    if (success) {
      this.props.onSelect(investor);
    }
    this.setState({modalOpen: false});
  };

  renderModal() {
    return (
      <Modal
        isOpen={this.state.modalOpen}
        contentLabel="Create New Investor"
      >
        <Investor investor={this.state.investor} onClose={this.onClose} />
      </Modal>
    );
  }

  renderNav() {
    return (
      <nav className="top-bar">
        <ul className="menu">
          <li>
            <input type="search" placeholder="Search our investor database..." className="typeahead top-search-bar" />
            <button type="button" className="button tiny search-button" onClick={this.onClick}>
              Add New Investor
            </button>
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