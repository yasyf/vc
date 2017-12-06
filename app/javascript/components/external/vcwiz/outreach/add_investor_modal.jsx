import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import { InvestorsFuzzySearchPath } from '../global/constants.js.erb';
import Typeahead from '../global/shared/typeahead';
import {fullName} from '../global/utils';
import PartnerHeading from '../global/competitors/partner_heading';
import StandardLoader from '../global/shared/standard_loader';

export default class AddInvestorModal extends React.Component {
  state = {
    isLoading: false,
  };

  renderSuggestion = suggestion => {
    return <PartnerHeading investor={suggestion} />
  };

  onLoading = isLoading => {
    this.setState({isLoading});
  };

  onSelect = suggestion => {
    this.props.onResult({investor: {id: suggestion.id}})
  };

  renderTop() {
    return <h3 className="title">Add an Investor</h3>;
  }

  renderBottom() {
    const { isLoading } = this.state;
    return [
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
      />,
      <StandardLoader key="loader" size={25} isLoading={isLoading} infoTag="h4" />,
    ];
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