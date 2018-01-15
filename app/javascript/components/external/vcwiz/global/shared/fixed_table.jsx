import React from 'react';
import {Table, Column, AutoSizer} from 'react-virtualized';
import ImageTextCell from '../cells/image_text_cell';
import TextArrayCell from '../cells/text_array_cell';
import TrackCell from '../cells/track_cell';
import TextCell from '../cells/text_cell';
import DatetimeCell from '../cells/datetime_cell';
import CompanyCell from '../cells/company_cell';
import IntroCell from '../cells/intro_cell';
import EmojiCell from '../cells/emoji_cell';
import CompetitorTrackCell from '../cells/competitor_track_cell';
import NullStateCell from '../cells/null_state_cell';
import PlaceholderCell from '../cells/placeholder_cell';
import {fromTableSD, isMobile, nullOrUndef, toTableSD} from '../utils';
import CompetitorCell from '../cells/competitor_cell';
import {SortDirection} from '../constants.js.erb';
import tableHeader from './table_header';

export default class FixedTable extends React.Component {
  static defaultProps = {
    rowHeight: 80,
    headerHeight: 50,
  };

  state = {
    sortBy: null,
    sortDirection: null,
  };

  onSort = ({ sortBy, sortDirection }) => {
    const {
      sortBy: prevSortBy,
      sortDirection: prevSortDirection
    } = this.state;

    let direction = fromTableSD(sortDirection);
    if (sortBy === prevSortBy && prevSortDirection === SortDirection.Desc) {
      direction = SortDirection.Natural;
    }

    this.props.onSort(sortBy, direction);
    this.setState({sortBy, sortDirection: direction});
  };

  rowGetter = ({ index }) => this.props.array.getSync(index);

  onCellClick = name => (e, row) => this.props.onCellClick(row, name);
  cellDataGetter = ({ rowData, dataKey }) => _.get(rowData, dataKey);

  cellRenderer = (CellComponent, key, props, trackClicks) => ({ rowIndex, cellData, rowData }) => (
    <CellComponent
      key={key}
      columnKey={key}
      rowIndex={rowIndex}
      row={rowData}
      data={cellData}
      isFaded={this.props.isFaded}
      onClick={(trackClicks && this.onCellClick(key)) || undefined}
      {...props}
    />
  );

  renderColumn(key, name, CellComponent, props = {}, width = undefined, flex = 1, trackClicks = true) {
    const disableSort = nullOrUndef(this.props.sort[key]);
    return (
      <Column
        key={key}
        dataKey={key}
        label={name}
        cellDataGetter={this.cellDataGetter}
        cellRenderer={this.cellRenderer(CellComponent, key, props, trackClicks)}
        flexGrow={flex || undefined}
        width={width || (isMobile() ? 200 : 50)}
        disableSort={disableSort}
        headerRenderer={disableSort ? undefined : tableHeader}
        headerClassName="header"
      />
    );
  }

  renderTextArrayColumn = (key, name, props) => {
    return this.renderColumn(key, name, TextArrayCell, props);
  };

  renderImageTextColumn = (key, name, props, flex = 1) => {
    return this.renderColumn(key, name, ImageTextCell, { size: this.props.rowHeight / 2 , ...props }, undefined, flex);
  };

  renderCompetitorColumn = (key, name, props, flex = 1) => {
    return this.renderColumn(key, name, CompetitorCell, { size: this.props.rowHeight / 2 , ...props }, undefined, flex);
  };

  renderTextColumn = (key, name, props, flex = 1) => {
    return this.renderColumn(key, name, TextCell, props, undefined, flex);
  };

  renderPlaceholderColumn = (key, name, flex = 1) => {
    return this.renderColumn(key, name, PlaceholderCell, {onChange: this.props.onRowUpdate}, undefined, flex);
  };

  renderDatetimeColumn = (key, name) => {
    return this.renderColumn(key, name, DatetimeCell);
  };

  renderCompanyColumn = (key, name) => {
    return this.renderColumn(key, name, CompanyCell, {}, undefined, 2);
  };

  renderTrackColumn = (key, onChange, name) => {
    return this.renderColumn(key, name, TrackCell, {onChange}, 200, null, false);
  };

  renderCompetitorTrackColumn = (key, onChange, name) => {
    let props = {onChange, onButtonClick: this.onCellClick(key)};
    return this.renderColumn(key, name, CompetitorTrackCell, props, 200, null, false);
  };

  renderIntroColumn = (key, name, props) => {
    return this.renderColumn(key, name, IntroCell, props, 200, null);
  };

  renderEmojiColumn = (key, name, props) => {
    return this.renderColumn(key, name, EmojiCell, props, 100, null);
  };

  renderNullState = () => <NullStateCell />;

  rowStyle = ({ index }) => ({
    backgroundColor: index % 2 === 0 ? undefined : '#f6f7f8',
  });

  render() {
    const { rowHeight, headerHeight, count, array, sort: allSort } = this.props;
    const sort = _.pickBy(allSort, Boolean);
    let sortBy, direction;
    if (!_.isEmpty(sort)) {
      [sortBy, direction] = Object.entries(sort)[0];
      direction = toTableSD(direction);
      sortBy = direction ? sortBy : null;
    }
    return (
      <div className="fixed-table">
        <AutoSizer>
          {({ width, height }) => (
            <Table
              estimatedRowSize={rowHeight}
              rowHeight={rowHeight}
              headerHeight={headerHeight}
              rowCount={count}
              width={width}
              height={height}
              rowGetter={this.rowGetter}
              rowStyle={this.rowStyle}
              className="table-main"
              sort={this.onSort}
              sortBy={sortBy}
              sortDirection={direction}
              noRowsRenderer={this.renderNullState}
              overscanRowCount={10}
            >
              {this.renderColumns()}
            </Table>
          )}
        </AutoSizer>
      </div>
    );
  }
}