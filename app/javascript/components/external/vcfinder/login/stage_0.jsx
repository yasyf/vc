import React from 'react';
import {LoginPath} from '../constants.js.erb'

export default class VCFinderLoginStage0 extends React.Component {
  render() {
    return (
      <div>
        <div>
          <h4>VCWiz helps early stage founders find relevant investors.</h4>
          <h5>Please log in with your company Google account.</h5>
        </div>
        <div className="pad-top">
          <a className="button" href={LoginPath}>
            Login with Google
          </a>
        </div>
      </div>
    );
  }
}