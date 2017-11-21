import React from 'react';
import {UnpureTextCell} from './text_cell';
import Track from '../fields/track';
import Store from '../store';
import {TargetInvestorsPath} from '../constants.js.erb';

export default class TrackCell extends UnpureTextCell {
  processRow(props, row) {
    const { target_investors } = Store.get('founder');
    const target = _.find(target_investors, {id: row.id});
    return {value: target.stage, id: row.id};
  };

  setSubscription() {
    this.subscription = Store.subscribe('founder', ({target_investors}) => {
      if (!this.state.id) {
        return;
      }
      const target = _.find(target_investors, {id: this.state.id});
      this.setState({value: target.stage});
    });
  }

  componentDidMount() {
    super.componentDidMount();
    this.setSubscription();
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.rowIndex !== this.props.rowIndex) {
      Store.unsubscribe(this.subscription);
      this.setSubscription();
    }
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  renderValue() {
    return (
      <div className='track-cell'>
        <Track
          name={this.props.columnKey}
          value={this.state.value}
          onChange={this.onChange}
        />
      </div>
    )
  }
}