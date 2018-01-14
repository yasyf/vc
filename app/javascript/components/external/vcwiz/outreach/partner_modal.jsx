import React from 'react';
import {TargetInvestorsPath} from '../global/constants.js.erb';
import OverlayModal from '../global/shared/overlay_modal';
import PartnerTab from '../global/competitors/partner_tab';
import ResearchModal from '../global/competitors/research_modal';
import {ffetch} from '../global/utils';
import Actions from '../global/actions';
import hasModalErrorBoundary from '../global/shared/has_modal_error_boundary';

@hasModalErrorBoundary
export default class PartnerModal extends OverlayModal {
  onTrackChange = update => {
    const { id } = this.props.item;
    ffetch(TargetInvestorsPath.id(id), 'PATCH', {target_investor: {stage: update.track.value}}).then(() => {
      Actions.trigger('refreshFounder');
    });
  };

  investor() {
    let { investor } = this.props.item;
    if (!investor) {
      const { firm_name, first_name, last_name, role } = this.props.item;
      investor = {
        first_name,
        last_name,
        role,
        competitor: {
          name: firm_name,
        },
      };
    }
    return investor;
  }

  competitor() {
    const investor = this.investor();
    const { competitor } = investor;
    return {
      partners: [investor],
      ...competitor,
    };
  }

  renderResearch() {
    const { item, ...rest } = this.props;
    return (
      <ResearchModal {...rest} item={this.competitor()} onTrackChange={this.onTrackChange} />
    );
  }

  renderPartner() {
    return (
      <OverlayModal
        name="partner"
        top={<PartnerTab investor={this.investor()} onTrackChange={this.onTrackChange} />}
        bottom={null}
        {...this.props}
      />
    );
  }

  render() {
    if (this.props.item.investor) {
      return this.renderResearch();
    } else {
      return this.renderPartner();
    }
  }
}