import React from 'react';
import HotTable from 'react-handsontable';
import {
  TargetInvestorStages,
  TargetInvestorStagesInverse,
  CompetitorIndustries,
  CompetitorIndustriesInverse,
  CompetitorFundTypes,
  CompetitorFundTypesInverse,
  InvestorsSearchPath,
  IntroRequestsPath,
} from './constants.js.erb';
import {buildQuery, ffetch, nullOrUndef, extend} from './utils';
import {
  autocomplete,
  lazyAutocomplete,
  simple,
  nestedHeaders,
  flattenedColumns,
  flattenedHeaders,
  propToPath,
  nested,
  extractSchema,
  requestable,
} from './handsontable';

const autofillPaths = ['first_name', 'last_name', 'firm_name'];

export default class TargetInvestors extends React.Component {
  constructor(props) {
    super(props);

    this.hot = {};
    this.columns = this.genColumns();
    this.selectedCol = null;
  }

  componentDidUpdate() {
    if (!nullOrUndef(this.props.selected)) {
      let i = this.hot.getPlugin('columnSorting').untranslateRow(this.props.selected);
      this.hot.selectCell(i, this.selectedCol);
    }
  }

  getRow(i) {
    if (this.hot.sortingEnabled && this.hot.sortOrder !== undefined) {
      let ii = this.hot.sortIndex[i][0];
      return this.hot.getSourceDataAtRow(ii);
    } else {
      return this.hot.getSourceDataAtRow(i);
    }
  }

  onRemoveRow = (index, num) => {
    console.log('remove', index, num);
    // destroy records
  };

  onBeforeChange = (changes, source) => {
    if (source !== 'edit' || changes.length !== 1) {
      return;
    }
    let [i, prop, oldVal, newVal] = changes[0];

    if (!autofillPaths.includes(prop) && !prop.base) {
      return;
    }

    let sourceRow = this.getRow(i);

    if (prop.base) {
      let oldBase = _.get(sourceRow, prop.base);
      let newRow = _.set({[prop.base]: oldBase}, prop.path, prop.inverse[newVal]);
      let newBase = _.compact(_.get(newRow, prop.base));
      changes[0] = [i, prop.base, oldBase, newBase];
    }

    if (!autofillPaths.includes(prop)) {
      return;
    }

    let row = extend(sourceRow, {[prop]: newVal});

    for (let path of autofillPaths) {
      if (nullOrUndef(_.get(row, path))) {
        return;
      }
    }

    let query = buildQuery(row, autofillPaths);
    let newChanges = [[i, prop, newVal]];
    ffetch(`${InvestorsSearchPath}?${query.join('&')}`).then(res => {
      if (!res.length) {
        this.hot.setDataAtRowProp(newChanges);
        return;
      }
      let result = {
        investor: res[0],
        ...res[0],
      };
      Object.values(this.columns).forEach(prop => {
        _.castArray(propToPath(prop)).forEach(path => {
          if (nullOrUndef(_.get(row, path))) {
            let val = _.get(result, path);
            if (!nullOrUndef(val)) {
              newChanges.push([i, path, val]);
            }
          }
        });
      });
      this.hot.setDataAtRowProp(newChanges);
    });
    return false;
  };

  onChange = (changes, source) => {
    switch (source) {
      case 'loadData':
        if (this.hot.sortingEnabled && this.hot.sortOrder !== undefined) {
          this.hot.sort(this.hot.sortColumn, this.hot.sortOrder);
        }
        break;
      case 'CopyPaste.paste':
      case 'edit':
        let updates = {};
        changes.forEach(([i, prop, oldVal, newVal]) => {
          let path, value;
          if (typeof prop === 'function') {
            path = prop.path;
            value = prop.inverse[newVal];
          } else {
            path = prop;
            value = newVal;
          }
          updates[i] = _.set(updates[i] || {}, path, value);
        });
        Object.entries(updates).forEach(([i, update]) => {
          let row = this.getRow(i);
          if (row.id) {
            this.props.onTargetChange(row.id, update);
          } else {
            let len = _.keys(_.omitBy(update, v => nullOrUndef(v) || v === "")).length;
            if (len) {
              this.props.onNewTarget(update);
            }
          }
        });
        break;
    }
  };

  onSelection = (r, c) => {
    this.selectedCol = c;
  };

  genColumns() {
    let remote = _.bind(lazyAutocomplete, this, InvestorsSearchPath, autofillPaths);

    return {
      'Firm': remote('firm_name', 'competitor.name'),
      'First <br/> Name': remote('first_name'),
      'Last <br/> Name': remote('last_name'),
      'Role': simple('role'),
      'Email': requestable('email', 'has_email?', 'email_requested?', IntroRequestsPath),
      'Status': autocomplete(TargetInvestorStages, TargetInvestorStagesInverse, 'stage'),
      'Industry': nested(_.partial(autocomplete, CompetitorIndustries, CompetitorIndustriesInverse), 'industry', 3),
      'Type': autocomplete(CompetitorFundTypes, CompetitorFundTypesInverse, 'fund_type[0]'),
      'Note': simple('note'),
      'Last <br/> Response': simple('last_response'),
    };
  };


  render() {
    return (
      <div className="spreadsheet">
        <HotTable
          data={JSON.parse(JSON.stringify(this.props.targets))}
          dataSchema={extractSchema(this.columns)}
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
          minRows={10}
          minSpareRows={1}
          bindRowsWithHeaders={true}
          columnSorting={{
            sortEmptyCells: false,
          }}
          sortIndicator={true}
          onBeforeChange={this.onBeforeChange}
          onAfterChange={this.onChange}
          onAfterRemoveRow={this.onRemoveRow}
          onAfterSelection={this.onSelection}
          ref={hot => { if (hot) { this.hot = hot.hotInstance; } }}
        />
      </div>
    );
  }
}
