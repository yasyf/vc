import React from 'react';
import Modal from 'react-modal';
import { InvestorsFuzzySearchPath, InvestorsPath, FounderClickPath } from './constants.js.erb';
import SearchCreate from './search/create';
import Investor from './investor';
import {fullName, ffetch} from './utils';
import SearchFilters from './search/filters';
import SearchResult from './search/result';

Modal.defaultStyles.overlay.zIndex = 1000;

const Modals = {
  INVESTOR: 'INVESTOR',
  FILTERS: 'FILTERS',
};

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
      modal: null,
      investor: null,
    };
  }

  componentDidMount() {
    this.typeahead = $('.typeahead');
    let typeahead = this.typeahead;

    typeahead.bind('typeahead:beforeselect', (event, investor) => {
      this.onOpenInvestor(investor);
      typeahead.typeahead('val', '');
      typeahead.typeahead('close');
      event.preventDefault();
    });

    typeahead.bind('vcwiz:createinvestor', (event, query) => {
      this.onOpenInvestor(query);
    });

    typeahead.typeahead({
      minLength: 3,
      highlight: true,
    }, {
      limit: 5,
      source: this.engine,
      templates: {
        suggestion: props => ReactDOMServer.renderToStaticMarkup(<SearchResult {...props}/>),
        notFound: Handlebars.compile($('#no-result-template').html()),
      },
    });
  }

  onCloseModal = () => {
    this.setState({modal: null});
  };

  onOpenInvestor = (investor) => {
    ffetch(FounderClickPath, 'POST', {investor: {id: investor.id}});
    this.setState({modal: Modals.INVESTOR, investor});
  };

  onOpenFilter = () => {
    this.setState({modal: Modals.FILTERS});
  };

  onCloseInvestor = (success, investor) => {
    if (success) {
      this.props.onSelect(investor);
    }
    this.onCloseModal();
  };

  renderInvestorModal() {
    if (!this.state.investor) {
      return null;
    }
    return (
      <Modal
        isOpen={this.state.modal === Modals.INVESTOR}
        onRequestClose={this.onCloseModal}
        contentLabel={fullName(this.state.investor)}
      >
        <Investor investor={this.state.investor} onClose={this.onCloseInvestor} />
      </Modal>
    );
  }

  renderFilterModal() {
    return (
      <Modal
        isOpen={this.state.modal === Modals.FILTERS}
        onRequestClose={this.onCloseModal}
        contentLabel={'Investor Search Filters'}
      >
        <SearchFilters onClose={this.onCloseModal} />
      </Modal>
    );
  }

  renderNav() {
    return (
      <nav className="top-bar">
        <ul className="menu">
          <li>
            <input type="search" placeholder="Search our investor database..." className="typeahead top-search-bar" />
            <button type="button" className="button tiny search-button" onClick={this.onOpenFilter}>
              Filter
            </button>
          </li>
        </ul>
      </nav>
    );
  }

  render() {
    return (
      <div>
        {this.renderInvestorModal()}
        {this.renderFilterModal()}
        {this.renderNav()}
      </div>
    );
  }
}
