import React from 'react';
import CompetitorBase from './competitor_base';
import OverlayModal from '../shared/overlay_modal';

export default class ResearchModal extends CompetitorBase {
  render() {
    const { item } = this.props;
    const { tab } = this.state;
    return (
      <OverlayModal
        name="research"
        idParams={{item, tab}}
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}