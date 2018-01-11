import React from 'react';
import {PrivacyPolicyPath, TermOfUsePath} from '../constants.js.erb';

export default class Footer extends React.Component {
  render() {
    return (
      <footer className="global-footer">
        <div>
          Shipped with &hearts; by <a href="https://drf.vc" target="_blank">Dorm Room Fund</a>
        </div>
        <div>
          <a href={PrivacyPolicyPath} target="_blank">privacy</a>
          <span className="sep">|</span>
          <a href={TermOfUsePath} target="_blank">terms</a>
          <span className="sep">|</span>
          <a href="https://www.twitter.com/yasyf" target="_blank">@yasyf</a> if things break
        </div>
      </footer>
    )
  }
}