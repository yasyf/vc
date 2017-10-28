import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import { InvestorsFuzzySearchPath } from '../global/constants.js.erb';
import Typeahead from '../global/shared/typeahead';
import {fullName} from '../global/utils';
import PartnerHeading from '../global/competitors/partner_heading';

export default class AddInvestorModal extends React.Component {
  renderSuggestion = suggestion => {
    return <PartnerHeading investor={suggestion} />
  };

  onSelect = suggestion => {
    this.props.onResult({investor: {id: suggestion.id}})
  };

  renderTop() {
    return <h3 className="title">Add an Investor</h3>;
  }

  renderBottom() {
    return (
      <Typeahead
        dataFields={['name', 'firm']}
        path={InvestorsFuzzySearchPath}
        getSuggestionValue={fullName}
        renderSuggestion={this.renderSuggestion}
        placeholder="Type a name or firm..."
        onSelect={this.onSelect}
      />
    );
  }

  render() {
    return (
      <OverlayModal
        name="add_investor"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}