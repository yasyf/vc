import React from 'react';
import VCWiz from '../vcwiz';
import Conversations from './conversations';
import {Column, Row} from 'react-foundation';
import AddInvestorModal from './add_investor_modal';
import { TargetInvestorsPath } from '../global/constants.js.erb';
import {ffetch, replaceSort, timestamp} from '../global/utils';
import Actions from '../global/actions';
import Storeage from '../global/storage.js.erb';
import ImportInvestorsModal from './import_investors_modal';
import SectionWithDims from '../global/shared/section_with_dims';
import EmailIntegrationModal from './email_integration_modal';

const Modals = {
  ADD: 'Add',
  IMPORT: 'Import',
  INTEGRATION: 'Integration',
};

const EmailInetegrationModalShown = 'EmailIntegrationModalShown';

export default class OutreachPage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      openModal: null,
      resultsId: timestamp(),
      targets: this.props.targets,
      sort: props.sort,
      count: props.count,
    };
  }

  componentDidMount() {
    if (!Storeage.get(EmailInetegrationModalShown)) {
      Storeage.set(EmailInetegrationModalShown, true);
      this.openEmailIntegrationModal();
    }
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
      Actions.trigger('refreshFounder');
    })
  };

  openAddModal = () => {
    this.setState({openModal: Modals.ADD});
  };

  openImportModal = () => {
    this.setState({openModal: Modals.IMPORT});
  };

  openEmailIntegrationModal = () => {
    this.setState({openModal: Modals.INTEGRATION});
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
      case Modals.INTEGRATION:
        return (
          <EmailIntegrationModal
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
        <Column large={5}>
          <h3>My Conversations</h3>
        </Column>
        <Column offsetOnLarge={4} large={3}>
          <div className="actions">
            <a onClick={this.openAddModal}>Add investor</a>
            <span className="sep">|</span>
            <a onClick={this.openImportModal}>Import</a>
            <span className="sep">|</span>
            <a onClick={this.openEmailIntegrationModal}>Email Integration</a>
          </div>
        </Column>
      </Row>
    );
  }

  renderBody() {
    const { sort, count, targets, resultsId } = this.state;
    const source = {path: TargetInvestorsPath, query: {sort}};

    return (
      <SectionWithDims dimensionsKey="dimensions">
        <Conversations
          resultsId={resultsId}
          source={source}
          onSort={this.onSort}
          {...this.props}
          targets={targets}
          sort={sort}
          count={count}
        />
      </SectionWithDims>
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