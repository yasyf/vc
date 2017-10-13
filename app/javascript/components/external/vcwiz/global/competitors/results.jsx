import React from 'react';
import Dimensions from 'react-dimensions';
import inflection from 'inflection';
import {timestamp} from '../utils';
import {CompetitorFundTypes, CompetitorIndustries} from '../constants.js.erb';
import LazyArray from '../lazy_array';
import {Table, Column, Cell} from 'fixed-data-table-2';
import ImageTextCell from '../cells/image_text_cell';
import TextArrayCell from '../cells/text_array_cell';
import TrackCell from '../cells/track_cell';
import TextCell from '../cells/text_cell';
import DatetimeCell from '../cells/datetime_cell';
import CompanyCell from '../cells/company_cell';

@Dimensions()
class ResultsTable extends React.Component {
  constructor(props) {
    super(props);

    this.state = this.nextState(props);
  }

  nextState(props) {
    return {
      array: new LazyArray(props.source, props.competitors, this.onArrayUpdate),
      lastUpdate: timestamp(),
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.resultsId !== this.props.resultsId) {
      this.setState(this.nextState(nextProps));
    }
  }

  onArrayUpdate = () => {
    this.setState({lastUpdate: timestamp()});
  };

  defaultMiddleColumns() {
    return [
      { type: 'text_array', key: 'fund_type', name: 'Types', translate: CompetitorFundTypes },
      { type: 'text_array', key: 'location', name: 'Locations'},
      { type: 'text_array', key: 'industry', name: 'Industries', translate: CompetitorIndustries},
    ]
  }

  renderColumn(key, name, cell, width = 50) {
    return (
      <Column
        key={key}
        columnKey={key}
        header={<Cell className="header">{name}</Cell>}
        cell={cell}
        flexGrow={1}
        width={50}
      />
    );
  }

  middleColumns() {
    const cols = this.props.columns || this.defaultMiddleColumns();
    const prefix = this.props.columns ? 'meta.' : '';
    return cols.map(({type, key, name, ...args}) => {
      let method = this[`render${inflection.camelize(type)}Column`];
      return method(`${prefix}${key}`, name, args);
    });
  }

  renderTextArrayColumn = (key, name, { translate }) => {
    return this.renderColumn(key, name, <TextArrayCell data={this.state.array} translate={translate} />);
  };

  renderImageTextColumn = (key, name, { imageKey, fallbackKey }) => {
    return this.renderColumn(key, name, <ImageTextCell data={this.state.array} imageKey={imageKey} fallbackKey={fallbackKey} />);
  };

  renderTextColumn = (key, name) => {
    return this.renderColumn(key, name, <TextCell data={this.state.array} />);
  };

  renderDatetimeColumn = (key, name) => {
    return this.renderColumn(key, name, <DatetimeCell data={this.state.array} />);
  };

  renderCompanyColumn = (key, name) => {
    return this.renderColumn(key, name, <CompanyCell data={this.state.array} />);
  };

  renderTrackColumn = (key, name) => {
    return this.renderColumn(key, name, <TrackCell data={this.state.array} />, 150);
  };

  render() {
    return (
      <Table
        rowHeight={100}
        headerHeight={50}
        rowsCount={this.props.count}
        width={this.props.containerWidth}
        height={this.props.containerHeight}
        showScrollbarX={false}
        showScrollbarY={false}
        className="table-main"
      >
        {this.renderImageTextColumn('name', 'Firm', { imageKey: 'photo', fallbackKey: 'acronym' })}
        {this.middleColumns()}
        {this.renderTrackColumn('track', 'Track')}
      </Table>
    );
  }
}

export default class Results extends React.Component {
  render() {
    return (
      <div className="results-table">
        <ResultsTable {...this.props} />
      </div>
    )
  }
}