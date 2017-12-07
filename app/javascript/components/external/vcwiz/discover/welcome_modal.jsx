import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import Store from '../global/store';
import {Button, Colors} from 'react-foundation';

export default class WelcomeModal extends React.Component {
  renderTop() {
    const { first_name } = Store.get('founder', {});
    return <h3>Welcome to VCWiz {first_name}!</h3>;
  }

  renderBottom() {
    return (
      <div className="info">
        <p>
          Welcome to VCWiz! We're so excited to help you on your fundraising journey.
        </p>
        <h4>Research & Discovery</h4>
        <p>
          This page will help you discover investors to raise your round from.
          We've compiled the most comprehensive database of investors on the internet, including data on the types of investments individual partners at firms like to make.
          We've also partnered with <a href="https://knowyourvc.com/" target="_blank">Know Your VC</a> to incorporate reviews from other founders!
        </p>
        <p>
          In the middle section of this page, you can filter investors by categories like city, fund type, and industry, or search by partner or firm name.
          Below the filters section, you'll find lists of investors which have been curated just for you!
        </p>
        <h4>Outreach</h4>
        <p className="tight">
          VCWiz also has a full conversation tracker built in, which can help facilitate introductions to investors, as well as track your outreach.
          As you discover promising investors, use the "Track" button to add them to your tracker.
        </p>
        <p className="tight">
          It looks like this:
          <Button color={Colors.SECONDARY} className="fake-track-button">
            Track
          </Button>
        </p>
        <p>
          You can also import existing spreadsheets of investors, and automatically sync your conversations with your email account.
          Check out the "My Conversations" page for more details!
        </p>
      </div>
    );
  }

  render() {
    return (
      <OverlayModal
        name="welcome"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}