import React from 'react';
import {isLoggedIn} from '../utils';
import {TargetInvestorStages} from '../constants.js.erb'

export default class Sidebar extends React.Component {
  renderEvent = ({action, arg1, arg2, first_name, last_name}) => {
    const name = `${first_name} ${_.first(last_name)}.`;
    switch (action) {
      case 'investor_opened':
        return `${name} opened your ${arg1 ? 'intro' : 'email'}`;
      case 'investor_replied':
        return `${name} replied to your ${arg2 ? 'intro' : 'email'}`;
      case 'investor_clicked':
        return <span>{name} clicked your <a href={arg1} target="_blank">link</a></span>;
      default:
        return null;
    }
  };

  renderEvents() {
    const { events } = window.gon.founder;
    if (!events) {
      return null;
    }
    const activities = events.map(e => <div key={e.id}>{this.renderEvent(e)}</div>);
    return [
      <h6 key="activity">Recent Activity</h6>,
      ...activities,
    ];
  }

  renderConversations() {
    const { conversations } = window.gon.founder;
    if (!conversations) {
      return null;
    }
    const groups = Object.entries(conversations.counts).map(([name, count]) =>
      <div key={name}>{TargetInvestorStages[name]} ({count})</div>
    );
    const recents = conversations.recents.map(name =>
      <div key={name}>{name}</div>
    );
    const more = (
      <div key="more">
        {conversations.total > recents.length ? `+${conversations.total - recents.length} More` : null}
      </div>
    );
    return [
      <p className="title" key="title">Conversations</p>,
      <h6 key="stage">Stage</h6>,
      ...groups,
      <h6 key="recent">Recently Added</h6>,
      ...recents,
      more,
    ];
  }

  render() {
    if (!isLoggedIn()) {
      return null;
    }
    return (
      <div className="sidebar full-height">
        {this.renderConversations()}
        {this.renderEvents()}
      </div>
    );
  }
}