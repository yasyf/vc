import React from 'react';
import {FilterPath, SearchPath, FilterTypes} from '../global/constants.js.erb';
import Tabs from '../global/tabs/tabs';
import FilterPage from '../filter/filter_page';
import inflection from 'inflection';

const MaxCount = 100;

export default class Hero extends React.Component {
  state = {
    query: '',
    count: 0,
    tab: 0,
  };

  onTabChange = tab => {
    this.setState({tab});
  };


  onQueryChange = (query, count) => {
    this.setState({query, count});
  };

  renderViewAll() {
    const { query, count } = this.state;
    const clipped = Math.min(count, MaxCount);
    const path = this.state.tab === FilterTypes.SEARCH ? SearchPath : FilterPath;
    return (
      <div className="view-all">
        <a href={`${path}?${query}`}>
          View
          {' '}
          {clipped !== 1 ? 'all' : null}
          {' '}
          {clipped && clipped !== MaxCount ? clipped : null}
          {' '}
          {clipped !== MaxCount ? inflection.inflect('results', clipped) : `${clipped}+ results`}
        </a>
      </div>
    );
  }

  renderBrowse() {
    return (
      <div>
        <FilterPage
          {...this.props}
          types={this.state.tab}
          onQueryChange={this.onQueryChange}
          rowHeight={60}
          industryLimit={2}
          fullHeight={true}
          applySuggestions={true}
          render={(header, body) => (
            <div>
              {header}
              <div className="results">{body}</div>
            </div>
          )}
        />
        {this.renderViewAll()}
      </div>
    );
  }

  render() {
    return (
      <div className="search-hero">
        <div className="welcome">
          <h3><b>Find Your Perfect Investors</b></h3>
          <p>
            Use the filters to browse through different groups of investors, or use the search tab to find an investor by name or firm.
            Click on a firm's name to view a comprehensive research report on all its investors and investments.
          </p>
        </div>
        <Tabs
          tabs={['Filter investors', 'Search for an investor', "Find a startup's investors"]}
          panels={[null, null]}
          onTabChange={this.onTabChange}
        />
        {this.renderBrowse()}
      </div>
    )
  }
}