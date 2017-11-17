import React from 'react';
import VCWiz from '../vcwiz';
import { canUseDOM } from 'exenv';
import createHistory from 'history/createBrowserHistory'
import FilterPage from '../filter/filter_page';

export default class Search extends React.Component {
  constructor(props) {
    super(props);

    if (canUseDOM) {
      this.history = createHistory();
    }
  }

  pushState = query => {
    if (this.history) {
      this.history.push({search: `?${query}`});
    }
  };

  render() {
    return (
      <FilterPage
        {...this.props}
        title="Find an Investor"
        showFilters={false}
        onQueryChange={this.pushState}
        render={(header, body) => (
          <VCWiz
            page="search"
            header={header}
            body={body}
          />
        )}
      />
    );
  }
}