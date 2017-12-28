import React from 'react';
import VCWiz from '../vcwiz';
import ModalPage from '../global/shared/modal_page';
import PartnerTab from '../global/competitors/partner_tab';
import { TargetInvestorsPath } from '../global/constants.js.erb';
import Actions from '../global/actions';
import {ffetch} from '../global/utils';
import Lists from '../discover/lists';

export default class InvestorPage extends React.Component {
  onTrackChange = update => {
    ffetch(TargetInvestorsPath.id(this.props.item.id), 'PATCH', {target_investor: {stage: update.track.value}}).then(() => {
      Actions.trigger('refreshFounder');
    });
  };

  renderBody() {
    const { item, review, interactions } = this.props;
    return (
      <ModalPage
        name="research"
        top={<PartnerTab initiallyExpanded={true} investor={item} review={review} interactions={interactions} fetch={false} onTrackChange={this.onTrackChange} />}
      />
    );
  }

  render() {
    return (
      <VCWiz
        page="investor"
        body={this.renderBody()}
        footer={<Lists />}
        showIntro={true}
      />
    );
  }
}