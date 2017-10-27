import React from 'react';
import VCWiz from '../vcwiz';
import Results from '../global/competitors/results';
import {CompetitorsListPath} from '../global/constants.js.erb';

export default class ListPage extends React.Component {
  renderBody() {
    let { columns, competitors, count, name, title } = this.props;

    return (
      <div className="full-screen">
        <p className="title">{title}</p>
        <Results
          count={count}
          competitors={competitors}
          columns={columns}
          source={{path: CompetitorsListPath.id(name), query: {}}}
          resultsId={1}
        />
      </div>
    );
  }

  render() {
    return (
      <VCWiz
        page="list"
        body={this.renderBody()}
      />
    );
  }
}