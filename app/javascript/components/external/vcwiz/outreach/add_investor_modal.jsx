import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import InvestorTypeahead from './investor_typeahead';
import hasModalErrorBoundary from '../global/shared/has_modal_error_boundary';

@hasModalErrorBoundary
export default class AddInvestorModal extends React.Component {
  renderTop() {
    return <h3 className="title">Add an Investor</h3>;
  }

  render() {
    const { onResult } = this.props;
    return (
      <OverlayModal
        name="add_investor"
        top={this.renderTop()}
        bottom={<InvestorTypeahead onResult={onResult} />}
        {...this.props}
      />
    );
  }
}