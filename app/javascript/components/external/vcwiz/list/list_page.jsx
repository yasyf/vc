import React from 'react';
import Results from '../global/competitors/results';
import {CompetitorsListPath} from '../global/constants.js.erb';

export default class ListPage extends React.Component {
  render() {
    let { columns, competitors, count, title, name } = this.props;
    return (
      <div className="full-screen list-page">
        <div className="list-page-header">
          <p className="title">{title}</p>
        </div>
        <div className="list-page-body full-screen">
          <Results
            count={count}
            competitors={competitors}
            columns={columns}
            source={{path: CompetitorsListPath.id(name), query: {}}}
            resultsId={1}
          />
        </div>
      </div>
    )
  }
}