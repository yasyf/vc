import React from 'react';
import HotTable from 'react-handsontable';
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
import {
  autocomplete, autocompleteDeep, simple, nestedHeaders, flattenedColumns,
  flattenedHeaders,
} from './handsontable';

let columns = {
  'First Name': simple('investor.first_name'),
  'Last Name': simple('investor.last_name'),
  'Role': simple('investor.role'),
  'Firm': simple('investor.competitor.name'),
  'Status': autocomplete(TargetInvestorStages, TargetInvestorStagesInverse, 'stage'),
  'Industry': [
    autocompleteDeep(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[0]'),
    autocompleteDeep(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[1]'),
    autocompleteDeep(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[2]'),
  ],
  'Check Size': autocompleteDeep(CompetitorFundingSizes, CompetitorFundingSizesInverse, 'funding_size'),
  'Note': simple('note'),
};

export default class TargetInvestors extends React.Component {
  constructor(props) {
    super(props);

    this.hot = {};
  }

  componentDidMount() {
    this.hot.sort(this.hot.getColHeader().indexOf('Status'), true);
    setTimeout(() => this.hot.getPlugin('collapsibleColumns').collapseAll(), 1000);
  }

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

  onChange = (changes, source) => {
    switch (source) {
      case 'loadData':
        if (this.hot.sortingEnabled) {
          this.hot.sort(this.hot.sortColumn, this.hot.sortOrder);
        }
        break;
      case 'edit':
        changes.forEach(([i, prop, oldVal, newVal]) => {
          if (oldVal === newVal) {
            return;
          }
          let row;
          if (this.hot.sortingEnabled) {
            let ii = this.hot.sortIndex[i][0];
            row = this.props.targets[ii];
          } else {
            row = this.props.targets[i];
          }
          let id = row.id;

          let path, value;
          if (typeof prop === 'function') {
            path = prop.path;
            value = prop.inverse[newVal];
          } else {
            path = prop;
            value = newVal;
          }

          let update = _.set({}, path, value);
          this.props.onTargetChange(id, update);
        });
        break;
    }
  };

  render() {
    return (
      <div className="spreadsheet">
        <HotTable
          data={this.props.targets}
          colHeaders={flattenedHeaders(columns)}
          nestedHeaders={[nestedHeaders(columns)]}
          columns={flattenedColumns(columns)}
          stretchH="all"
          preventOverflow='horizontal'
          autoColumnSize={{
            useHeaders: true
          }}
          manualColumnResize={true}
          collapsibleColumns={true}
          autoRowSize={true}
          hiddenColumns={{
            indicators: true,
          }}
          contextMenu={['hidden_columns_hide', 'hidden_columns_show']}
          minSpareRows={1}
          bindRowsWithHeaders={true}
          columnSorting={{
            sortEmptyCells: true,
          }}
          sortIndicator={true}
          onAfterChange={this.onChange}
          ref={hot => { if (hot) { this.hot = hot.hotInstance; } }}
        />
      </div>
    );
  }
}
