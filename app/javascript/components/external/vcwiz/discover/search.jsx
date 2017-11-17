import React from 'react';
import {Icon} from 'react-foundation';
import PlaceholderInput from '../global/fields/placeholder_input';

export default class Search extends React.Component {
  onChange = name => value => {
    this.props.onChange({[name]: value});
  };

  renderSearchLine(name, description) {
    return (
      <div className="line float-center">
        <Icon name="fi-magnifying-glass icon reversed" />
        <PlaceholderInput
          value={this.props.value[name]}
          placeholder={description}
          onChange={this.onChange(name)}
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