import React from 'react';
import Search from './search';
import {FilterPath, CompetitorsFilterCountPath} from '../global/constants.js.erb';
import Tabs from '../global/tabs/tabs';
import FilterPage from '../filter/filter_page';
import inflection from 'inflection';

export default class SearchHero extends React.Component {
  state = {
    query: '',
    count: 0,
  };


  onQueryChange = (query, count) => {
    this.setState({query, count});
  };

  renderViewAll() {
    const { query, count } = this.state;
    return (
      <div className="view-all">
        <a href={`${FilterPath}?${query}`}>
          View {count !== 1 ? 'all' : null} {count || null} {inflection.inflect('results', count)}
        </a>
      </div>
    );
  }

  renderBrowse() {
    return (
      <div>
        <FilterPage
          {...this.props}
          onQueryChange={this.onQueryChange}
          showSearch={false}
          rowHeight={60}
          industryLimit={2}
          overflowY="hidden"
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

  renderSearch() {
    return (
      <div className="search-and-filters float-center">
        <p className="or">or</p>
        <Search onChange={this.onSearchChange} onSubmit={this.onSubmit} />
      </div>
    );
  }


  render() {
    return (
      <div className="search-hero">
        <div className="welcome">
          <h3><b>Discover Seed-Stage Investors</b></h3>
          <p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit.
            Aenean commodo viverra blandit. In hac habitasse platea dictumst.
            Etiam mattis placerat augue ut scelerisque. In eget ultricies ipsum
          </p>
        </div>
        <Tabs
          tabs={['Browse Investors']}
          panels={[this.renderBrowse()]}
        />
      </div>
    )
  }
}