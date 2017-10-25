import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import PartnerTab from '../global/competitors/partner_tab';

export default class PartnerModal extends OverlayModal {
  onTrackChange = update => {
    this.props.onResult({stage: update.track.value}, true);
  };

  renderTop() {
    let { investor, stage } = this.props.item;
    return (
      <PartnerTab
        investor={investor}
        track={stage}
        onTrackChange={this.onTrackChange}
      />
    );
  }

  renderBottom() {
    return null;
  }
}