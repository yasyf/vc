import React from 'react';
import {Icon} from 'react-foundation';
import PlaceholderInput from '../global/fields/placeholder_input';

export default class Search extends React.Component {
  render() {
    return (
      <div className="search">
        <div className="line float-center">
          <Icon name="fi-magnifying-glass" className='icon' />
          <PlaceholderInput placeholder="Search by Firm or Partner..." onChange={this.props.onChange} />
        </div>
      </div>
    );
  }
}