import React from 'react';
import VCWiz from '../vcwiz';
import Conversations from './conversations';
import {Column, Row} from 'react-foundation';
import AddInvestorModal from './add_investor_modal';
import { TargetInvestorsPath } from '../global/constants.js.erb';
import {ffetch, timestamp} from '../global/utils';

export default class OutreachPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      isModalOpen: false,
      resultsId: timestamp(),
      targets: this.props.targets,
    };
  }

  onModalClose = () => {
    this.setState({isModalOpen: false});
  };

  onModalResult = update => {
    this.onModalClose();
    ffetch(TargetInvestorsPath.collectionResource('import'), 'POST', update).then(target => {
      this.setState({
        resultsId: timestamp(),
        targets: [target].concat(this.state.targets),
      });
    })
  };

  openModal = () => {
    this.setState({isModalOpen: true});
  };

  renderModal() {
    return (
      <AddInvestorModal
        isOpen={this.state.isModalOpen}
        onClose={this.onModalClose}
        onResult={this.onModalResult}
      />
    );
  }

  renderHeader() {
    return (
      <Row>
        <Column large={3}>
          <span className="title">Your Conversations</span>
        </Column>
        <Column offsetOnLarge={6} large={3}>
          <div className="text-right">
            <a onClick={this.openModal}>+ Add investor</a>
          </div>
        </Column>
      </Row>
    );
  }

  renderBody() {
    let { targets, ...props } = this.props;
    targets = this.state.targets;
    return (
      <Conversations
        resultsId={this.state.resultsId}
        targets={targets}
        {...props}
      />
    )
  }

  render() {
    return (
      <VCWiz
        page="outreach"
        header={this.renderHeader()}
        body={this.renderBody()}
        modal={this.renderModal()}
      />
    );
  }
}