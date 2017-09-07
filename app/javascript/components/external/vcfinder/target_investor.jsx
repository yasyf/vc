import React from 'react';
import moment from 'moment';
import inflection from 'inflection';
import {pronoun, wordJoin} from './utils';

export default class TargetInvestor extends React.Component {
  renderLastResponse(targetInvestor) {
    let { last_responded, first_name, firm_name, intro_request, gender } = targetInvestor;
    if (last_responded) {
      return <span><b>{first_name}</b> last responded to you {moment(last_response).fromNow()}</span>
    } else {
      let busy = intro_request['traveling?'] ? null : <span>{inflection.titleize(pronoun(gender, 'pos'))} job at {firm_name} must be keeping {pronoun(gender, 'past')} busy!</span>;
      return <span><b>{first_name}</b> hasn't responded to you yet. {busy}</span>;
    }
  }

  renderClicks(targetInvestor) {
    let { first_name, intro_request } = targetInvestor;
    if (!intro_request.id) {
      return null;
    }
    let clicks = Object.
      entries(intro_request.clicks).
      filter(([k, v]) => v).
      map(([k, v]) => k === 'website' ? k : inflection.titleize(k));
    if (!clicks.length) {
      return null;
    }
    return <span>{first_name} has checked out your <b>{wordJoin(clicks)}</b>.</span>;
  }

  renderIntroRequest(targetInvestor) {
    let { first_name, intro_request } = targetInvestor;
    if (!intro_request.id) {
      return null;
    } else if (intro_request.opened_at && !intro_request.accepted) {
      let reason = intro_request.reason ? <span>, because "{intro_request.reason}"</span> : null;
      return <span>You requested an intro, but {first_name} was <b>not interested</b>{reason}.</span>;
    } else if (intro_request.accepted === true) {
      return <span>You requested an intro, and {first_name} is <b>interested in speaking with you</b>.</span>;
    } else if (intro_request.opened_at) {
      return <span>You've requested an intro, and {first_name} last opened the request <b>{moment(intro_request.opened_at).fromNow()}</b></span>;
    } else {
      return <span>You've requested an intro, but so far we have <b>no response</b> from {first_name}.</span>;
    }
  }

  renderLocation(targetInvestor) {
    let { first_name, intro_request, gender } = targetInvestor;
    if (!intro_request.open_city) {
      return null;
    }
    let traveling = intro_request['traveling?'] ? <span>Heads up! {first_name} is traveling.</span> : null;
    return <span>{traveling} We last saw {pronoun(gender, 'past')} in <b>{intro_request.open_city}</b> {moment(intro_request.opened_at).fromNow()}.</span>
  }

  render() {
    let targetInvestor = this.props.targetInvestor;
    if (!targetInvestor.intro_request)
      targetInvestor.intro_request = {};

    return (
      <div className="card float-center investor">
        <p>{this.renderLastResponse(targetInvestor)}</p>
        <p>{this.renderClicks(targetInvestor)}</p>
        <p>{this.renderIntroRequest(targetInvestor)}</p>
        <p>{this.renderLocation(targetInvestor)}</p>
      </div>
    );
  }
}