import React from 'react';
import TrackCell from './track_cell';
import {Button, Colors} from 'react-foundation';
import {nullOrUndef} from '../utils';
import Store from '../store';

export default class CompetitorTrackCell extends TrackCell {
  processRow(props, row) {
    const { target_investors } = Store.get('founder');
    const target = _.find(target_investors, {competitor_id: row.id});
    if (target) {
      return {value: target.stage, id: target.id, rowId: row.id};
    } else {
      return {rowId: row.id};
    }
  };

  setSubscription() {
    this.subscription = Store.subscribe('founder', ({target_investors}) => {
      if (!this.state.rowId) {
        return;
      }
      const target = _.find(target_investors, {competitor_id: this.state.rowId});
      if (target)
        this.setState({value: target.stage});
    });
  }

  onButtonClick = e => {
    this.props.onButtonClick(e, this.props.rowIndex);
  };

  renderValue() {
    if (!nullOrUndef(this.state.value)) {
      return super.renderValue();
    } else {
      return (
        <div className="track-cell">
          <Button onClick={this.onButtonClick} color={Colors.SECONDARY} className="fake-track-button">
            SELECT
          </Button>
        </div>
      );
    }
  }
}