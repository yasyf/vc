import React from 'react';
import HotTable from 'react-handsontable';
import TargetInvestor from './target_investor';
import Buttons from './buttons';
import {
  TargetInvestorStages,
  TargetInvestorStagesInverse,
  CompetitorIndustries,
  CompetitorIndustriesInverse,
  CompetitorFundingSizes,
  CompetitorFundingSizesInverse,
} from './constants.js.erb';
import {pluckSort} from './utils';
import {autocomplete, autocompleteDeep, simple} from './handsontable'

export default class TargetInvestors extends React.Component {
  renderStageButtons() {
    let stages = pluckSort(this.props.targets, 'stage', Object.keys(TargetInvestorStages));
    let labeled = _.zip(stages, _.map(stages, s => TargetInvestorStages[s]));
    return (
      <Buttons
        categories={labeled}
        current={this.props.stage}
        onChange={this.props.onStageChange}
        alwaysShow={true}
        icon="arrow-right"
      />
    );
  }

  render() {
    let columns = {
      'First Name': simple('investor.first_name'),
      'Last Name': simple('investor.last_name'),
      'Role': simple('investor.role'),
      'Firm': simple('investor.competitor.name'),
      'Status': autocomplete(TargetInvestorStages, TargetInvestorStagesInverse, 'stage'),
      'Industry 1': autocompleteDeep(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[0]'),
      'Industry 2': autocompleteDeep(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[1]'),
      'Industry 3': autocompleteDeep(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[2]'),
      'Check Size': autocompleteDeep(CompetitorFundingSizes, CompetitorFundingSizesInverse, 'funding_size'),
      'Note': simple('note'),
    };

    return (
      <div className="spreadsheet">
        <HotTable
          data={this.props.targets}
          colHeaders={Object.keys(columns)}
          columns={Object.values(columns)}
          stretchH="all"
          preventOverflow='horizontal'
          minSpareRows={1}
          bindRowsWithHeaders={true}
          columnSorting={{
            column: Object.keys(columns).indexOf('Status')
          }}
        />
      </div>
    );
  }
}
