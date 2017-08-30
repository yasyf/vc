import React from 'react';
import SearchResult from './search/result';
import {buildQuery, ffetch} from './utils';
import {InvestorsFilterPath} from './constants.js.erb';

export default class Investors extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      investors: [],
    };
  }

  componentDidMount() {
    this.fetchInvestors(this.props.filters);
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.filters !== this.props.filters) {
      this.fetchInvestors(nextProps.filters);
    }
  }

  fetchInvestors(filters) {
    ffetch(`${InvestorsFilterPath}?${buildQuery(filters).join('&')}`).then(investors => {
      this.setState({investors, loading: false});
    });
  }

  render() {
    if (this.state.loading) {
      return <div>'Loading...'</div>;
    }

    if (!this.state.investors.length) {
      return <div>No results!</div>;
    }

    let investors = this.state.investors.map(inv => <SearchResult key={inv.id} {...inv} />);
    return <div>{investors}</div>;
  }
}