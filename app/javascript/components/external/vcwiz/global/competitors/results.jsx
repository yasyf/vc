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
import ResearchModal from './research_modal';

@Dimensions()
class ResultsTable extends React.Component {
  defaultMiddleColumns() {
    return [
      { type: 'text_array', key: 'fund_type', name: 'Types', translate: CompetitorFundTypes },
      { type: 'text_array', key: 'location', name: 'Locations'},
      { type: 'text_array', key: 'industry', name: 'Industries', translate: CompetitorIndustries},
    ]
  }

  renderColumn(key, name, cell, width = 50, flex = 1) {
    return (
      <Column
        key={key}
        columnKey={key}
        header={<Cell className="header">{name}</Cell>}
        cell={cell}
        flexGrow={flex || undefined}
        width={width}
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
    return this.renderColumn(key, name, <TextArrayCell data={this.props.array} onClick={this.props.onRowClick} translate={translate} />);
  };

  renderImageTextColumn = (key, name, { imageKey, fallbackKey }) => {
    return this.renderColumn(key, name, <ImageTextCell data={this.props.array} onClick={this.props.onRowClick} imageKey={imageKey} fallbackKey={fallbackKey} />);
  };

  renderTextColumn = (key, name) => {
    return this.renderColumn(key, name, <TextCell data={this.props.array} onClick={this.props.onRowClick} />);
  };

  renderDatetimeColumn = (key, name) => {
    return this.renderColumn(key, name, <DatetimeCell data={this.props.array} onClick={this.props.onRowClick} />);
  };

  renderCompanyColumn = (key, name) => {
    return this.renderColumn(key, name, <CompanyCell data={this.props.array} />);
  };

  renderTrackColumn = (key, name) => {
    return this.renderColumn(key, name, <TrackCell data={this.props.array} />, 150, null);
  };

  render() {
    return (
      <div className="results-table">
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
      </div>
    );
  }
}

export default class Results extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      currentModal: null,
      ...this.state = this.nextState(props),
    };
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

  onModalClose = () => {
    this.setState({currentModal: null});
  };

  onRowClick = (e, i) => {
    this.setState({currentModal: i});
  };

  renderCurrentModal() {
    const { currentModal, array } = this.state;
    if (currentModal === null) {
      return null;
    }
    return (
      <ResearchModal
        onClose={this.onModalClose}
        {...array.getSync(currentModal)}
      />
    );
  }

  render() {
    const { array } = this.state;
    return (
      <div className="full-screen">
        {this.renderCurrentModal()}
        <ResultsTable onRowClick={this.onRowClick} array={array} {...this.props} />
      </div>
    )
  }
}