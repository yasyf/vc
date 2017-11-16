import React from 'react';
import FilterPage from './filter_page';
import VCWiz from '../vcwiz';
import { canUseDOM } from 'exenv';
import createHistory from 'history/createBrowserHistory'

export default class Filter extends React.Component {
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
        title="Filter Investors"
        showSearch={false}
        onQueryChange={this.pushState}
        render={(header, body) => (
          <VCWiz
            page="filter"
            header={header}
            body={body}
          />
        )}
      />
    );
  }
}