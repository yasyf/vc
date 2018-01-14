import React from 'react';
import VCWiz from '../vcwiz';
import CompanyCard from '../discover/company_card';
import { isLoggedIn } from '../global/utils';
import { CompetitorsFilterPath } from '../global/constants.js.erb';
import Results from '../global/competitors/results';

export default class ComanyPage extends React.Component {
  renderBody() {
    const { path, list } = this.props;
    const { columns, competitors, count } = list;

    return (
      <Results
        count={count}
        competitors={competitors}
        columns={columns}
        source={{path: path, query: {}}}
        resultsId={1}
      />
    );
  }

  render() {
    return (
      <VCWiz
        page="company"
        header={<CompanyCard company={this.props.item} />}
        body={this.renderBody()}
        showIntro={!isLoggedIn()}
        fullScreen={true}
        inlineSignup={true}
      />
    );
  }
}