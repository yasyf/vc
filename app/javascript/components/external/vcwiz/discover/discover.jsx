import React from 'react';
import VCWiz  from '../vcwiz';
import Hero from './hero';
import Lists from './lists';
import WelcomeModal from './welcome_modal';

const WelcomeModalShown = 'WelcomeModalShown';

export default class Discovery extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      welcomeModalOpen: !!props.is_new_login,
    };
  };

  onModalClose = () => {
    this.setState({welcomeModalOpen: false});
  };

  renderModal() {
    if (!this.state.welcomeModalOpen) {
      return null;
    }
    return (
      <WelcomeModal
        isOpen={true}
        onClose={this.onModalClose}
      />
    );
  }

  render() {
    return (
      <VCWiz
        page="discover"
        header={<Hero {...this.props} />}
        body={<Lists />}
        modal={this.renderModal()}
        showIntro={true}
      />
    );
  }
}