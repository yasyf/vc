import React from 'react';
import Select from './select';
import {TargetInvestorStagesOptions} from '../constants.js.erb'
import {Button, Colors} from 'react-foundation';
import Actions from '../actions';
import {isLoggedIn} from '../utils';

const nullRenderer = () => null;

export default class Track extends React.Component {
  static defaultProps = {
    name: 'track',
  };

  onButtonClick = () => {
    Actions.trigger('signup');
  };

  render() {
    if (isLoggedIn()) {
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
    } else {
      return (
        <Button onClick={this.onButtonClick} color={Colors.SUCCESS} className="fake-track-button">
          Track
        </Button>
      );
    }
  }
}