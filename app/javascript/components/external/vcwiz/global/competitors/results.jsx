import React from 'react';
import inflection from 'inflection';
import {CompetitorFundTypes, CompetitorIndustries} from '../constants.js.erb';
import ResearchModal from './research_modal';
import WrappedTable from '../shared/wrapped_table';
import FixedTable from '../shared/fixed_table';

class ResultsTable extends FixedTable {
  defaultMiddleColumns() {
    return [
      { type: 'text_array', key: 'fund_type', name: 'Types', translate: CompetitorFundTypes },
      { type: 'text_array', key: 'location', name: 'Locations' },
      { type: 'text_array', key: 'industry', name: 'Industries', translate: CompetitorIndustries },
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

  renderColumns() {
    return [
      this.renderImageTextColumn('name', 'Firm', { imageKey: 'photo', fallbackKey: 'acronym' }),
      this.middleColumns(),
      this.renderTrackColumn('track', 'Track'),
    ];
  }
}

export default class Results extends React.Component {
  render() {
    let { competitors, ...props } = this.props;
    return (
      <WrappedTable
        items={competitors}
        modal={key => key !== 'track' && ResearchModal}
        table={ResultsTable}
        {...props}
      />
    );
  }
}