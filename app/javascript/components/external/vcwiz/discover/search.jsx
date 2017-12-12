import React from 'react';
import {Icon} from 'react-foundation';
import PlaceholderInput from '../global/fields/placeholder_input';

export default class Search extends React.Component {
  renderSearchLine(name, description) {
    return (
      <div className="line float-center">
        <Icon name="fi-magnifying-glass icon reversed" />
        <PlaceholderInput
          name={name}
          value={this.props.value[name]}
          debounced={true}
          placeholder={description}
          onChange={this.props.onChange}
        />
      </div>
    );
  }

  render() {
    return (
      <div className="search">
        {this.renderSearchLine('firm_name', 'Firm Name...')}
        {this.renderSearchLine('first_name', 'First Name...')}
        {this.renderSearchLine('last_name', 'Last Name...')}
      </div>
    )
  }
}