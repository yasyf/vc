import React from 'react';
import {Icon} from 'react-foundation';
import PlaceholderInput from '../global/fields/placeholder_input';

export default class Search extends React.Component {
  static defaultProps = {
    onSubmit: _.noop,
  };

  onKeyPress = (event) => {
    if (event.key === 'Enter') {
      this.props.onSubmit();
    }
  };

  render() {
    return (
      <div className="search">
        <div className="line float-center">
          <Icon name="fi-magnifying-glass" className='icon' />
          <PlaceholderInput
            value={this.props.value}
            placeholder="Search by Firm or Partner..."
            onChange={this.props.onChange}
            onKeyPress={this.onKeyPress}
          />
        </div>
      </div>
    );
  }
}