import React from 'react';
import { InvestorsFuzzySearchPath } from '../global/constants.js.erb';
import Typeahead from '../global/shared/typeahead';
import {fullName} from '../global/utils';
import PartnerHeading from '../global/competitors/partner_heading';
import StandardLoader from '../global/shared/standard_loader';

export default class InvestorTypeahead extends React.Component {
  state = {
    isLoading: false,
  };

  renderSuggestion = suggestion => {
    return <PartnerHeading transparency={this.props.transparency} investor={suggestion} />
  };

  onLoading = isLoading => {
    this.setState({isLoading});
  };

  onSelect = suggestion => {
    this.props.onResult({investor: {id: suggestion.id}})
  };

  render() {
    const { isLoading } = this.state;
    return (
      <div className="investor-typeahead">
        <Typeahead
          key="typeahead"
          dataFields={['name', 'firm']}
          path={InvestorsFuzzySearchPath}
          getSuggestionValue={fullName}
          renderSuggestion={this.renderSuggestion}
          placeholder="Type a name or firm..."
          useTether={false}
          onLoading={this.onLoading}
          onSelect={this.onSelect}
        />
        <StandardLoader key="loader" size={25} isLoading={isLoading} infoTag="h4" />
      </div>
    )
  }
}