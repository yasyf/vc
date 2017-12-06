import React from 'react';
import Select from './select';
import {TargetInvestorStagesOptions} from '../constants.js.erb'
import {Button, Colors} from 'react-foundation';
import Actions from '../actions';
import {isLoggedIn} from '../utils';

export default class Track extends React.Component {
  static defaultProps = {
    name: 'track',
  };

  onButtonClick = () => {
    Actions.trigger('signup');
  };

  renderOption = option => {
    return <span className={`track-option-${option.value.substr(2)}`}>{option.label}</span>;
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
            scrollMenuIntoView={false}
            tetherClassName="track-select-tether"
            options={TargetInvestorStagesOptions}
            arrowRenderer={this.props.value ? undefined : null}
            optionRenderer={this.renderOption}
            valueRenderer={this.renderOption}
            onChange={this.props.onChange}
          />
        </div>
      );
    } else {
      return (
        <Button onClick={this.onButtonClick} color={Colors.SECONDARY} className="fake-track-button">
          Track
        </Button>
      );
    }
  }
}