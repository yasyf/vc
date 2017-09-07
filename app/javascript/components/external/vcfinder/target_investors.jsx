import React from 'react';
import HotTable from 'react-handsontable';
import Modal from 'react-modal';
import TargetInvestor from './target_investor';

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
  flattenedColumns,
  flattenedHeaders,
  propToPath,
  extractSchema,
  requestable,
  button,
} from './handsontable';

const autofillPaths = ['first_name', 'last_name', 'firm_name'];

export default class TargetInvestors extends React.PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      detailTarget: null,
    };

    this.hot = {};
    this.columns = this.genColumns();
    this.selectedCol = null;
  }

  componentDidMount() {
    this.maxColWidths = this.genMaxColWidths();
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

  onModifyWidth = (w, c) => {
    if (!this.maxColWidths) {
      return;
    }
    if (w > this.maxColWidths[c]) {
      return this.maxColWidths[c];
    }
  };

  onRemoveRow = (index) => {
    let sourceRow = this.getRow(index);
    if (!sourceRow || !sourceRow.id) {
      return;
    }
    this.props.onDestroyTarget(sourceRow.id);
    this.hot.alter('remove_row', index);
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

  genMaxColWidths() {
    let keys = Object.keys(this.columns);
    let defaultWidth = $('.spreadsheet').width() / keys.length;
    let widths = {};
    keys.forEach(c => {
      widths[c] = defaultWidth;
    });
    widths['email'] = 100;
    widths['Status'] = 200;
    widths['Industry'] = 200;
    widths['Note'] = 350;
    return Object.values(widths);
  }

  genColumns() {
    let remote = _.bind(lazyAutocomplete, this, InvestorsSearchPath, autofillPaths);

    return {
      'Firm': remote('firm_name', 'competitor.name'),
      'First <br/> Name': remote('first_name'),
      'Last <br/> Name': remote('last_name'),
      'Role': simple('role'),
      'Email': requestable('email', 'has_email?', 'email_requested?', IntroRequestsPath),
      'Status': autocomplete(TargetInvestorStages, TargetInvestorStagesInverse, 'stage'),
      'Industry': autocomplete(CompetitorIndustries, CompetitorIndustriesInverse, 'industry[0]'),
      'Type': autocomplete(CompetitorFundTypes, CompetitorFundTypesInverse, 'fund_type[0]'),
      'Note': simple('note'),
      'Details': button('Details', this.onDetails),
    };
  };

  beforeOnCellMouseDown = (e, {row, col}) => {
    if (col === -1) {
      e.stopImmediatePropagation();
      this.onRemoveRow(row, 1);
    }
  };

  static genRowHeader(i) {
    return `<span data-index="${i}"><i class='fi-trash'></i></span>`
  };

  onDetails = (row) => {
    let detailTarget = this.getRow(row);
    this.setState({detailTarget});
  };

  onCloseModal = () => {
    this.setState({detailTarget: null});
  };

  renderModal() {
    return (
      <Modal
        isOpen={!!this.state.detailTarget}
        onRequestClose={this.onCloseModal}
        contentLabel={'Details'}
      >
        <TargetInvestor onClose={this.onCloseModal} targetInvestor={this.state.detailTarget} />
      </Modal>
    )
  }

  render() {
    return (
      <div>
        {this.renderModal()}
        <div className="spreadsheet">
          <HotTable
            data={JSON.parse(JSON.stringify(this.props.targets))}
            dataSchema={extractSchema(this.columns)}
            colHeaders={flattenedHeaders(this.columns)}
            rowHeaders={TargetInvestors.genRowHeader}
            columns={flattenedColumns(this.columns)}
            stretchH="all"
            preventOverflow='horizontal'
            autoColumnSize={{
              useHeaders: true,
            }}
            manualColumnResize={true}
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
            beforeOnCellMouseDown={this.beforeOnCellMouseDown}
            onAfterChange={this.onChange}
            onAfterSelection={this.onSelection}
            onModifyColWidth={this.onModifyWidth}
            ref={hot => { if (hot) { this.hot = hot.hotInstance; } }}
          />
        </div>
      </div>
    );
  }
}
