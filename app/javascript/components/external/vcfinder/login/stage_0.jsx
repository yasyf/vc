import React from 'react';
import {LoginPath} from '../constants.js.erb'

export default class VCFinderLoginStage0 extends React.Component {
  render() {
    return (
      <div>
        <div>
          <h4>Please log in with your company Google account.</h4>
        </div>
        <div>
          <a className="button" href={LoginPath}>
            Login with Google
          </a>
        </div>
      </div>
    );
  }
}