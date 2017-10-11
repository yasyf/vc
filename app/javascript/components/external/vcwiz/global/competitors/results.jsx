import React from 'react';
import Dimensions from 'react-dimensions';
import {CompetitorFundTypes, CompetitorIndustries} from '../constants.js.erb';
import LazyArray from '../lazy_array';
import {Table, Column, Cell} from 'fixed-data-table-2';
import ImageTextCell from '../cells/image_text_cell';
import TextArrayCell from '../cells/text_array_cell';
import TrackCell from '../cells/track_cell';
import {timestamp} from '../utils';

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
        <Column
          columnKey="name"
          header={<Cell className="header">Firm</Cell>}
          cell={<ImageTextCell data={this.state.array} imageKey="photo" fallbackKey="acronym" />}
          flexGrow={1}
          width={50}
        />
        <Column
          columnKey="fund_type"
          header={<Cell className="header">Types</Cell>}
          cell={<TextArrayCell data={this.state.array} translate={CompetitorFundTypes} />}
          flexGrow={1}
          width={50}
        />
        <Column
          columnKey="location"
          header={<Cell className="header">Locations</Cell>}
          cell={<TextArrayCell data={this.state.array} />}
          flexGrow={1}
          width={50}
        />
        <Column
          columnKey="industry"
          header={<Cell className="header">Industries</Cell>}
          cell={<TextArrayCell data={this.state.array} translate={CompetitorIndustries} />}
          flexGrow={1}
          width={50}
        />
        <Column
          columnKey="track"
          header={<Cell className="header">Track</Cell>}
          cell={<TrackCell data={this.state.array} />}
          width={150}
        />
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