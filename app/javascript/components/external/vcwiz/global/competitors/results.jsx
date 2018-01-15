import React from 'react';
import inflection from 'inflection';
import {CompetitorFundTypes, CompetitorIndustries, CompetitorsPath, StorageRestoreStateKey, LargeScreenSize, MobileScreenSize} from '../constants.js.erb';
import ResearchModal from './research_modal';
import WrappedTable from '../shared/wrapped_table';
import FixedTable from '../shared/fixed_table';
import {ffetch} from '../utils';
import Store from '../store';
import Actions from '../actions';

class ResultsTable extends FixedTable {
  parseColumns(columns, prefix = '') {
    return columns.map(({type, key, name, ...args}) => {
      let method = this[`render${inflection.camelize(type)}Column`];
      return method(`${prefix}${key}`, name, args);
    });
  }

  defaultMiddleColumns() {
    const { dimensions } = this.props;
    let { industryLimit } = this.props;
    industryLimit = industryLimit || (dimensions.width > LargeScreenSize ? 3 : 2);

    if (dimensions.width <= MobileScreenSize) {
      return [];
    }

    return [
      { type: 'text_array', key: 'fund_type', name: 'Types', translate: CompetitorFundTypes },
      { type: 'text', key: 'hq', name: 'Location' },
      { type: 'text_array', key: 'industry', name: 'Industries', translate: CompetitorIndustries, limit: industryLimit },
    ]
  }

  middleColumns() {
    if (this.props.columns) {
      return this.parseColumns(this.props.columns, 'meta.').concat(this.parseColumns(_.initial(this.defaultMiddleColumns())));
    } else {
      return this.parseColumns(this.defaultMiddleColumns());
    }
  }

  onTrackChange = (row, update) => {
    const id = this.props.array.getSync(row, false).id;
    ffetch(CompetitorsPath.id(id), 'PATCH', {competitor: update}).then(() => {
      Actions.trigger('refreshFounder');
    });
  };

  renderColumns() {
    return [
      this.renderCompetitorColumn('name', 'Firm', { imageKey: 'photo', fallbackKey: 'acronym' }, 1.25),
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