import React from 'react';
import Select from './select';
import {TargetInvestorStagesOptions} from '../constants.js.erb'

const nullRenderer = () => null;

export default class Track extends React.Component {
  static defaultProps = {
    name: 'track',
  };

  render() {
    return (
      <div className="track-button">
        <Select
          name={this.props.name}
          value={this.props.value}
          placeholder="Add"
          multi={false}
          searchable={false}
          onChange={this.props.onChange}
          options={TargetInvestorStagesOptions}
          arrowRenderer={this.props.value ? undefined : nullRenderer}
        />
      </div>
    );
  }
}