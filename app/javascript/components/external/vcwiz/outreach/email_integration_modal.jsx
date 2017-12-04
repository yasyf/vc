import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';

export default class EmailIntegrationModal extends React.Component {
  renderTop() {
    return <h3>Email Integration</h3>;
  }

  renderBottom() {
    return (
      <div className="info">
        VCWiz can automatically track your email conversations with investors!
        CC the email OR integrate with gmail below.
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean commodo viverra blandit. In hac habitasse platea dictumst. Etiam mattis placerat augue ut scelerisque. In eget ultricies ipsum.
      </div>
    );
  }

  render() {
    return (
      <OverlayModal
        name="email_integration"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}