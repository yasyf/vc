import React from 'react';
import {PrivacyPolicyPath} from '../constants.js.erb';

export default class Footer extends React.Component {
  render() {
    return (
      <footer className="global-footer">
        <div>
          Shipped with &hearts; by <a href="https://drf.vc" target="_blank">Dorm Room Fund</a>
          <span className="sep">|</span>
          <a href={PrivacyPolicyPath} target="_blank">Privacy Policy</a>
          <span className="sep">|</span>
          <a href="https://www.twitter.com/yasyf" target="_blank">@yasyf</a> if things break
        </div>
      </footer>
    )
  }
}