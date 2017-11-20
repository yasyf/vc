import React from 'react';
import {getDomain, isLoggedIn} from '../utils';
import {TargetInvestorCategories, OutreachPath, CCEmail} from '../constants.js.erb'
import {Button, Colors} from 'react-foundation';
import classNames from 'classnames';
import moment from 'moment';
import inflection from 'inflection';

const CategoryColors = {
  wishlist: '#2472DF',
  in_talks: '#2472DF',
  pitching: '#2472DF',
  passed: '#797C82',
  committed: '#3EAB1B',
};

export default class OutreachBar extends React.Component {
  onClick = () => {
    window.location.href = OutreachPath;
  };

  renderEvent = ({action, arg1, arg2, first_name, last_name, firm_name, email_subject}) => {
    const name = `${first_name} ${last_name} from ${firm_name}`;
    const email = email_subject ?  `email (${email_subject})` : 'email';
    switch (action) {
      case 'investor_opened':
        return `${name} opened your ${arg1 ? 'intro' : email}. Look forward to a response soon!`;
      case 'investor_replied':
        return `${name} replied to your ${arg1 ? 'intro' : email}. Make sure you follow up!`;
      case 'investor_clicked':
        return <span>{name} clicked your link to <a href={arg2} target="_blank">{getDomain(arg2)}</a>. I'm sure they were impressed!</span>;
      default:
        return null;
    }
  };

  renderReminder() {
    const { stats } = window.gon.founder;
    const { conversations } = window.gon.founder;
    if (conversations.total && _.isEmpty(stats)) {
      return (
        <span>
          You haven't sent any emails yet! Be sure to CC <b>{CCEmail}</b> in your emails to start tracking your investor outreach.
        </span>
      );
    }
    return (
      <span>
        Remember to include <b>{CCEmail}</b> in your emails so we can help analyze your outreach!
      </span>
    );
  }

  renderStats() {
    const { stats } = window.gon.founder;
    if (_.isEmpty(stats)) {
      return null;
    }
    const { response_time, emails, investors } = stats;
    if (!response_time) {
      return <span>So far, you've sent <b>{emails} emails</b>, to over <b>{investors} investors</b>.</span>
    } else {
      return (
        <span>
          So far, you've sent <b>{emails} emails</b> to over <b>{investors} investors</b> and have an average response time of <b>{moment.duration(stats.response_time, 'seconds').humanize()}</b>.
        </span>
      );
    }
  }

  renderEvents() {
    const { events } = window.gon.founder;
    if (!events || !events.length) {
      return null;
    }
    return (
      <div className="events">
        Recently, {this.renderEvent(_.sample(events))}
      </div>
    )
  }

  renderBusy() {
    const { conversations } = window.gon.founder;
    if (conversations.total) {
      return "You've been busy!";
    } else {
      return "Looks like you haven't picked out any investors to reach out to. Browse for investors below, or start including VCWiz on your existing email chains.";
    }
  }

  renderStatsAndEvents() {
    return (
      <div>
        {this.renderBusy()}
        {' '}
        {this.renderStats()}
        {' '}
        {this.renderReminder()}
        {' '}
        {this.renderEvents()}
      </div>
    )
  }

  renderConversation(key) {
    const { conversations } = window.gon.founder;
    const firms = conversations.recents[key] || [];
    const show = _.map(_.take(firms, 4), (f, i) => <div key={i}>{f}</div>);
    const left = firms.length - show.length;
    return (
      <div className={classNames('conversation-group', {'faded': !show.length})} key={key}>
        <div className="conversation-group-head" style={{backgroundColor: CategoryColors[key]}}>
          {inflection.titleize(key)} ({firms.length})
        </div>
        <div className="conversation-group-body">
          {show}
          {left ? `+ ${left} more` : null}
          {!show.length ? 'None yet!' : null}
        </div>
      </div>
    );
  }

  renderConversations() {
    return [
      this.renderConversation('wishlist'),
      this.renderConversation('in_talks'),
      this.renderConversation('pitching'),
      <hr key="vr" className="vr" />,
      this.renderConversation('passed'),
      this.renderConversation('committed'),
    ];
  }

  renderButton() {
    return (
      <div className="button-wrapper">
        <Button color={Colors.SECONDARY} onClick={this.onClick}>
          View Conversations
        </Button>
      </div>
    )
  }

  renderWelcome() {
    const { conversations } = window.gon.founder;
    if (conversations.total) {
      return `You're in talks with ${window.gon.founder.conversations.total} investors.`;
    } else {
      return "You're not tracking any investors yet!"
    }
  }

  render() {
    if (!isLoggedIn()) {
      return null;
    }
    return (
      <div className="outreach-bar">
        <h4>
          Hi {window.gon.founder.first_name}.
          {' '}
          {this.renderWelcome()}
        </h4>
        <div className="stats-and-events">{this.renderStatsAndEvents()}</div>
        <div className="conversations">{this.renderConversations()}</div>
        {this.renderButton()}
      </div>
    );
  }
}