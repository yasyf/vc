import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import PartnerTab from '../global/competitors/partner_tab';
import ResearchModal from '../global/competitors/research_modal';

export default class PartnerModal extends OverlayModal {
  onTrackChange = update => {
    this.props.onResult({stage: update.track.value}, true);
  };

  investor() {
    let { investor, stage } = this.props.item;
    if (!investor) {
      let { firm_name, first_name, last_name, role } = this.props.item;
      investor = {
        first_name,
        last_name,
        role,
        competitor: {
          name: firm_name,
        },
        target_investor: {
          stage: stage,
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