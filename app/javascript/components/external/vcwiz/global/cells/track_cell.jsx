import React from 'react';
import {UnpureTextCell} from './text_cell';
import Select from '../fields/select';
import {TargetInvestorStagesOptions} from '../constants.js.erb'
import DropdownOverlay from '../shared/dropdown_overlay';

const nullRenderer = () => null;

export default class TrackCell extends UnpureTextCell {
  onChange = change => {
    console.log(change);
    this.setState({value: change.track.value});
  };

  renderValue() {
    return (
      <Select
        name="track"
        value={this.state.value}
        placeholder="Add"
        multi={false}
        searchable={false}
        onChange={this.onChange}
        options={TargetInvestorStagesOptions}
        arrowRenderer={this.state.value ? undefined : nullRenderer}
        dropdownComponent={DropdownOverlay(() => this.select)}
        formRef={select => { this.select = select }}
      />
    )
  }
}