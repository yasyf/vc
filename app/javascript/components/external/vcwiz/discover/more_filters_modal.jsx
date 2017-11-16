import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import Switch from '../global/fields/switch';

export default class MoreFiltersModal extends React.Component {
  renderSwitch(name, label, description) {
    const { options, suggestions, onChange } = this.props;
    return (
      <Switch
        name={name}
        value={options[name]}
        highlight={suggestions.includes(name)}
        onChange={onChange}
        label={label}
        description={description}
      />
    );
  }

  renderTop() {
    return <h3>More Filters</h3>
  }

  renderBottom() {
    return (
      <div className="option-switches">
        {this.renderSwitch('us_only', 'US-Based', 'Only show investors based in the United States.')}
        {this.renderSwitch('related', 'Related Startups', 'Show investors who have invested in similar startups to the ones you selected.')}
        {this.renderSwitch('company_cities', 'Cities', 'Show investors who made investments in the given locations, instead of ones based there.')}
      </div>
    );
  }

  render() {
    return (
      <OverlayModal
        name="more_filters"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}