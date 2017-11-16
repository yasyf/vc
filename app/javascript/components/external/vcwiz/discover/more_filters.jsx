import React from 'react';
import {Button} from 'react-foundation';
import MoreFiltersModal from './more_filters_modal';

export default class MoreFilters extends React.Component {
  state = {
    modalOpen: false,
  };

  openModal = () => {
    this.setState({modalOpen: true});
  };

  closeModal = () => {
    this.setState({modalOpen: false});
  };

  renderModal() {
    if (!this.state.modalOpen) {
      return null;
    }
    return (
      <MoreFiltersModal
        key="modal"
        isOpen={this.state.modalOpen}
        options={this.props.options}
        suggestions={this.props.suggestions}
        onChange={this.props.onChange}
        onClose={this.closeModal}
      />
    );
  }

  render() {
    return [
      <hr key="vr" className="vr vr-hidden"/>,
      <div key="filter" className="filter filter-last">
        <div className="edit-button-wrapper more-filters-wrapper">
          <Button isHollow className="edit-button" onClick={this.openModal}>
            More Filters
          </Button>
        </div>
      </div>,
      this.renderModal(),
    ];
  }
}