import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import PartnerTab from '../global/competitors/partner_tab';

export default class PartnerModal extends OverlayModal {
  onTrackChange = update => {
    this.props.onResult({stage: update.track.value}, true);
  };

  renderTop() {
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
    return (
      <PartnerTab investor={investor} onTrackChange={this.onTrackChange} />
    );
  }

  renderBottom() {
    return null;
  }

  render() {
    return (
      <OverlayModal
        name="partner"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}