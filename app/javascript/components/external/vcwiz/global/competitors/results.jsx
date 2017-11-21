import React from 'react';
import inflection from 'inflection';
import {CompetitorFundTypes, CompetitorIndustries, TargetInvestorsPath, StorageRestoreStateKey} from '../constants.js.erb';
import ResearchModal from './research_modal';
import WrappedTable from '../shared/wrapped_table';
import FixedTable from '../shared/fixed_table';
import {ffetch} from '../utils';
import Store from '../store';
import Actions from '../actions';

class ResultsTable extends FixedTable {
  static defaultProps = {
    ...FixedTable.defaultProps,
    industryLimit: 3,
  };

  defaultMiddleColumns() {
    return [
      { type: 'text_array', key: 'fund_type', name: 'Types', translate: CompetitorFundTypes },
      { type: 'text', key: 'hq', name: 'Location' },
      { type: 'text_array', key: 'industry', name: 'Industries', translate: CompetitorIndustries, limit: this.props.industryLimit },
    ]
  }

  middleColumns() {
    const cols = this.props.columns || this.defaultMiddleColumns();
    const prefix = this.props.columns ? 'meta.' : '';
    return cols.map(({type, key, name, ...args}) => {
      let method = this[`render${inflection.camelize(type)}Column`];
      return method(`${prefix}${key}`, name, args);
    });
  }

  onTrackChange = (row, update) => {
    const id = this.props.array.getSync(row, false).id;
    const { target_investors } = Store.get('founder', {});
    const target = _.find(target_investors, {competitor_id: id});
    ffetch(TargetInvestorsPath.id(target.id), 'PATCH', {target_investor: update}).then(() => {
      Actions.trigger('refreshFounder');
    });
  };

  renderColumns() {
    return [
      this.renderImageTextColumn('name', 'Firm', { imageKey: 'photo', fallbackKey: 'acronym' }),
      this.middleColumns(),
      this.renderCompetitorTrackColumn('stage', this.onTrackChange, 'Track'),
    ];
  }
}

export default class Results extends React.Component {
  state = {
    restoreState: null,
  };

  componentWillMount() {
    this.subscription = Store.subscribe(StorageRestoreStateKey, restoreState => this.setState({restoreState}));
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  onModalClose = () => {
    this.setState({restoreState: null});
  };

  renderModal() {
    const { restoreState } = this.state;
    if (!restoreState || !restoreState.breadcrumb || restoreState.breadcrumb.name !== 'research') {
      return null;
    }
    return <ResearchModal {...restoreState.breadcrumb.params} key="modal" onClose={this.onModalClose} />
  }

  render() {
    let { competitors, ...rest } = this.props;
    return [
      this.renderModal(),
      <WrappedTable
        key="table"
        items={competitors}
        modal={ResearchModal}
        table={ResultsTable}
        {...rest}
      />,
    ];
  }
}