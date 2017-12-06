import React from 'react';
import {Table, Column} from 'fixed-data-table-2';
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
import Header from '../cells/header';
import PlaceholderCell from '../cells/placeholder_cell';

export default class FixedTable extends React.Component {
  static defaultProps = {
    rowHeight: 100,
    headerHeight: 50,
  };

  onCellClick = name => (e, row) => {
    this.props.onCellClick(row, name);
  };

  renderColumn(key, name, CellComponent, props = {}, width = 50, flex = 1, trackClicks = true) {
    return (
      <Column
        key={key}
        columnKey={key}
        header={<Header sort={this.props.sort} name={name} onSort={this.props.onSort} />}
        cell={
          <CellComponent
            data={this.props.array}
            isFaded={this.props.isFaded}
            onClick={(trackClicks && this.onCellClick(key)) || undefined}
            {...props}
          />
        }
        flexGrow={flex || undefined}
        width={width}
        allowCellsRecycling={true}
      />
    );
  }

  renderTextArrayColumn = (key, name, props) => {
    return this.renderColumn(key, name, TextArrayCell, props);
  };

  renderImageTextColumn = (key, name, props, flex = 1) => {
    return this.renderColumn(key, name, ImageTextCell, { size: this.props.rowHeight / 2 , ...props }, undefined, flex);
  };

  renderTextColumn = (key, name, props, flex = 1) => {
    return this.renderColumn(key, name, TextCell, props, undefined, flex);
  };

  renderPlaceholderColumn = (key, name, flex = 1) => {
    return this.renderColumn(key, name, PlaceholderCell, {onChange: this.props.onRowUpdate}, undefined, flex);
  };

  renderNullStateColumn = (flex = 1) => {
    return this.renderColumn(null, null, NullStateCell, {}, undefined, flex, false);
  };

  renderDatetimeColumn = (key, name) => {
    return this.renderColumn(key, name, DatetimeCell);
  };

  renderCompanyColumn = (key, name) => {
    return this.renderColumn(key, name, CompanyCell);
  };

  renderTrackColumn = (key, onChange, name) => {
    return this.renderColumn(key, name, TrackCell, {onChange}, 175, null, false);
  };

  renderCompetitorTrackColumn = (key, onChange, name) => {
    let props = {onChange, onButtonClick: this.onCellClick(key)};
    return this.renderColumn(key, name, CompetitorTrackCell, props, 175, null, false);
  };

  renderIntroColumn = (key, name, props) => {
    return this.renderColumn(key, name, IntroCell, props, 200, null);
  };

  renderEmojiColumn = (key, name, props) => {
    return this.renderColumn(key, name, EmojiCell, props, 150, null);
  };

  render() {
    const { rowHeight, headerHeight, count, dimensions, overflowY } = this.props;
    return (
      <div className="fixed-table">
        <Table
          rowHeight={rowHeight}
          headerHeight={headerHeight}
          rowsCount={count || 1}
          width={dimensions.width}
          height={dimensions.height}
          showScrollbarX={false}
          showScrollbarY={false}
          overflowY={overflowY}
          className="table-main"
        >
          {count ? this.renderColumns() : this.renderNullStateColumn()}
        </Table>
      </div>
    );
  }
}