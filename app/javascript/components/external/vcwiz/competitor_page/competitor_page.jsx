import React from 'react';
import VCWiz from '../vcwiz';
import CompetitorBase from '../global/competitors/competitor_base';
import ModalPage from '../global/shared/modal_page';
import Lists from '../discover/lists';

export default class CompetitorPage extends CompetitorBase {
  renderBody() {
    const { item } = this.props;
    return (
      <ModalPage
        name="research"
        top={this.renderTop()}
        bottom={this.renderBottom()}
      />
    );
  }

  render() {
    return (
      <VCWiz
        page="competitor"
        body={this.renderBody()}
        footer={<Lists />}
        showIntro={true}
        inlineSignup={true}
      />
    );
  }
}