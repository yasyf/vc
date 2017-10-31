import React from 'react';
import {Table, Column, Cell} from 'fixed-data-table-2';
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

export default class FixedTable extends React.Component {
  onCellClick = name => (e, row) => {
    this.props.onCellClick(row, name);
  };

  renderColumn(key, name, CellComponent, props = {}, width = 50, flex = 1, trackClicks = true) {
    return (
      <Column
        key={key}
        columnKey={key}
        header={<Cell className="header">{name}</Cell>}
        cell={
          <CellComponent
            data={this.props.array}
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

  renderTextArrayColumn = (key, name, { translate }) => {
    return this.renderColumn(key, name, TextArrayCell, {translate});
  };

  renderImageTextColumn = (key, name, props, flex = 1) => {
    return this.renderColumn(key, name, ImageTextCell, props, undefined, flex);
  };

  renderTextColumn = (key, name, flex = 1) => {
    return this.renderColumn(key, name, TextCell, {}, undefined, flex);
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

  renderTrackColumn = (key, name) => {
    return this.renderColumn(key, name, TrackCell, {onChange: this.props.onRowUpdate}, 150, null, false);
  };

  renderCompetitorTrackColumn = (key, onChange, name) => {
    let props = {onChange, onButtonClick: this.onCellClick(key)};
    return this.renderColumn(key, name, CompetitorTrackCell, props, 150, null, false);
  };

  renderIntroColumn = (key, name, props) => {
    return this.renderColumn(key, name, IntroCell, props, 200, null);
  };

  renderEmojiColumn = (key, name, props) => {
    return this.renderColumn(key, name, EmojiCell, props, 150, null);
  };

  render() {
    return (
      <div className="fixed-table">
        <Table
          rowHeight={100}
          headerHeight={50}
          rowsCount={this.props.count || 1}
          width={this.props.dimensions.width}
          height={this.props.dimensions.height}
          showScrollbarX={false}
          showScrollbarY={false}
          className="table-main"
        >
          {this.props.count ? this.renderColumns() : this.renderNullStateColumn()}
        </Table>
      </div>
    );
  }
}