import React from 'react';
import VCWiz from '../vcwiz';
import Results from '../global/competitors/results';
import {CompetitorsListPath} from '../global/constants.js.erb';
import SectionWithDims from '../global/shared/section_with_dims';

export default class ListPage extends React.Component {
  renderHeader() {
    let { title } = this.props;
    return <p className="title">{title}</p>;
  }

  renderBody() {
    let { columns, competitors, count, name } = this.props;

    return (
      <SectionWithDims dimensionsKey="dimensions">
        <Results
          count={count}
          competitors={competitors}
          columns={columns}
          source={{path: CompetitorsListPath.id(name), query: {}}}
          resultsId={1}
        />
      </SectionWithDims>
    );
  }

  render() {
    return (
      <VCWiz
        page="list"
        header={this.renderHeader()}
        body={this.renderBody()}
      />
    );
  }
}