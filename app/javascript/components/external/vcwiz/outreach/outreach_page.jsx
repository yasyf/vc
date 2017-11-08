import React from 'react';
import VCWiz from '../vcwiz';
import Conversations from './conversations';
import {Column, Row} from 'react-foundation';
import AddInvestorModal from './add_investor_modal';
import { TargetInvestorsPath } from '../global/constants.js.erb';
import {ffetch, replaceSort, timestamp} from '../global/utils';
import ImportInvestorsModal from './import_investors_modal';

const Modals = {
  ADD: 'Add',
  IMPORT: 'Import',
};

export default class OutreachPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      openModal: null,
      resultsId: timestamp(),
      targets: this.props.targets,
      sort: props.sort,
    };
  }

  onSort = (key, direction) => {
    const sort = replaceSort(key, direction, this.state.sort);
    this.setState({sort, resultsId: timestamp(), targets: null});
  };

  onModalClose = () => {
    this.setState({openModal: null});
  };

  onModalResult = update => {
    this.onModalClose();
    ffetch(TargetInvestorsPath.collectionResource('import'), 'POST', update).then(newTarget => {
      const { targets, count } = this.state;
      this.setState({
        resultsId: timestamp(),
        count: count + 1,
        targets: targets && [newTarget].concat(targets),
      });
    })
  };

  openAddModal = () => {
    this.setState({openModal: Modals.ADD});
  };

  openImportModal = () => {
    this.setState({openModal: Modals.IMPORT});
  };

  renderModal() {
    switch (this.state.openModal) {
      case Modals.ADD:
        return (
          <AddInvestorModal
            isOpen={true}
            onClose={this.onModalClose}
            onResult={this.onModalResult}
          />
        );
      case Modals.IMPORT:
        return (
          <ImportInvestorsModal
            isOpen={true}
            onClose={this.onModalClose}
            onResult={this.onModalResult}
          />
        );
      default:
        return null;
    }
  }

  renderHeader() {
    return (
      <Row>
        <Column large={3}>
          <div className="title-wrapper">
            <span className="title">Your Conversations</span>
            <a onClick={this.openImportModal}>Import</a>
          </div>
        </Column>
        <Column offsetOnLarge={6} large={3}>
          <div className="text-right">
            <a onClick={this.openAddModal}>+ Add investor</a>
          </div>
        </Column>
      </Row>
    );
  }

  renderBody() {
    const { sort, targets, resultsId } = this.state;
    const source = {path: TargetInvestorsPath, query: {sort}};

    return (
      <div className="full-screen">
        {this.renderHeader()}
        <Conversations
          resultsId={resultsId}
          source={source}
          onSort={this.onSort}
          {...this.props}
          targets={targets}
          sort={sort}
        />
      </div>
    )
  }

  render() {
    return (
      <VCWiz
        page="outreach"
        body={this.renderBody()}
        modal={this.renderModal()}
      />
    );
  }
}