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
  InvestorsSearchPath,
} from './constants.js.erb';
import {buildQuery, ffetch, pluckSort} from './utils';
import {
  autocomplete,
  lazyAutocomplete,
  simple,
  nestedHeaders,
  flattenedColumns,
  flattenedHeaders,
  propToPath,
  nested,
} from './handsontable';

const autofillPaths = {
  first_name: 'investor.first_name',
  last_name: 'investor.last_name',
  competitor: 'investor.competitor.name',
};

export default class TargetInvestors extends React.Component {
  constructor(props) {
    super(props);

    this.hot = {};
    this.columns = this.genColumns();
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

  getRow(i) {
    if (this.hot.sortingEnabled) {
      let ii = this.hot.sortIndex[i][0];
      return this.props.targets[ii];
    } else {
      return this.props.targets[i];
    }
  }

  onCreateRow = (index, num, source) => {
    console.log('add', index, num, source);
    // create new records
  };

  onRemoveRow = (index, num) => {
    console.log('remove', index, num);
    // destroy records
  };

  onBeforeChange = (changes, source) => {
    if (source !== 'edit' || changes.length !== 1) {
      return;
    }
    let [i, prop, oldVal, newVal] = changes[0];
    let paths = Object.values(autofillPaths);
    if (!paths.includes(prop)) {
      return;
    }

    let row = this.getRow(i);

    for (let path of paths) {
      if (_.get(row, path) === undefined) {
        return;
      }
    }

    let query = buildQuery(autofillPaths, row);
    ffetch(`${InvestorsSearchPath}?${query.join('&')}`).then(res => {
      let result = {
        investor: res[0],
        ...res[0],
      };
      let changes = _.compact(_.flatMap(Object.values(this.columns), prop => {
        let paths = _.castArray(propToPath(prop));
        return _.map(paths, path => {
          if (!_.get(row, path)) {
            let val = _.get(result, path);
            if (val !== null && val !== undefined) {
              return [i, path, val];
            }
          }
          return null;
        });
      }));
      this.hot.setDataAtRowProp(changes);
    });
  };

  onChange = (changes, source) => {
    switch (source) {
      case 'loadData':
        if (this.hot.sortingEnabled) {
          this.hot.sort(this.hot.sortColumn, this.hot.sortOrder);
        }
        break;
      case 'edit':
        let updates = {};
        changes.forEach(([i, prop, oldVal, newVal]) => {
          if (oldVal === newVal) {
            return;
          }
          let row = this.getRow(i);

          let path, value;
          if (typeof prop === 'function') {
            path = prop.path;
            value = prop.inverse[newVal];
          } else {
            path = prop;
            value = newVal;
          }

          let change = updates[row.id] || {};
          let update = _.set(change, path, value);
          updates[row.id] = update;
        });
        Object.entries(updates).forEach(([id, update]) => {
          this.props.onTargetChange(id, update);
        });
        break;
    }
  };

  genColumns() {
    let remote = _.bind(lazyAutocomplete, this, InvestorsSearchPath, autofillPaths);

    return {
      'Firm': remote('investor.competitor.name'),
      'First Name': remote('investor.first_name'),
      'Last Name': remote('investor.last_name'),
      'Role': simple('investor.role'),
      'Status': autocomplete(TargetInvestorStages, TargetInvestorStagesInverse, 'stage'),
      'Industry': nested(_.partial(autocomplete, CompetitorIndustries, CompetitorIndustriesInverse), 'industry', 3),
      'Check Size': autocomplete(CompetitorFundingSizes, CompetitorFundingSizesInverse, 'funding_size'),
      'Note': simple('note'),
    };
  };

  render() {
    return (
      <div className="spreadsheet">
        <HotTable
          data={this.props.targets}
          colHeaders={flattenedHeaders(this.columns)}
          nestedHeaders={[nestedHeaders(this.columns)]}
          columns={flattenedColumns(this.columns)}
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
          onBeforeChange={this.onBeforeChange}
          onAfterChange={this.onChange}
          onAfterCreateRow={this.onCreateRow}
          onAfterRemoveRow={this.onRemoveRow}
          ref={hot => { if (hot) { this.hot = hot.hotInstance; } }}
        />
      </div>
    );
  }
}
