import React from 'react';
import VCWiz from '../vcwiz';
import Results from '../global/competitors/results';
import SectionWithDims from '../global/shared/section_with_dims';
import Lists from '../discover/lists';

export default class ListPage extends React.Component {
  renderHeader() {
    let { heading, description } = this.props;
    return (
      <div>
        <h3>{heading}</h3>
        {description}
      </div>
    );
  }

  renderBody() {
    let { columns, competitors, count, name, path } = this.props;

    return (
      <SectionWithDims dimensionsKey="dimensions">
        <Results
          count={count}
          competitors={competitors}
          columns={columns}
          source={{path: path, query: {}}}
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
        footer={<Lists />}
      />
    );
  }
}