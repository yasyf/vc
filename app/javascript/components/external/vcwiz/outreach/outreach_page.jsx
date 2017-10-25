import React from 'react';
import Conversations from './conversations';
import {Column, Row} from 'react-foundation';

export default class OutreachPage extends React.Component {
  render() {
    return (
      <div className="outreach-page full-screen">
        <div className="outreach-page-header">
          <Row>
            <Column large={3}>
              <span className="title">Your Conversations</span>
            </Column>
            <Column offsetOnLarge={6} large={3}>
              <div className="text-right">
                <a>+ Add investor</a>
              </div>
            </Column>
          </Row>
        </div>
        <div className="outreach-page-body full-screen">
          <Conversations {...this.props} />
        </div>
      </div>
    );
  }
}