import React from 'react';
import {ffetch} from '../utils';
import {FounderPath} from '../constants.js.erb';
import SavedText from '../saved_text';
import SavedTextArea from '../saved_text_area';
import SavedChoice from '../saved_choice';

export default class VCFinderLoginStage extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      founder: null,
    };
  }

  componentDidMount() {
    ffetch(FounderPath).then(founder => this.setState({founder}));
  }

  onCompanyChange = (change) => {
    return ffetch(FounderPath, 'PATCH', {founder: change})
            .then(founder => this.setState({founder}));
  };

  renderSavedText(label, path, name) {
    return (
      <SavedText
        name={name}
        value={_.get(this, `state.founder.${path}.${name}`)}
        label={label}
        onChange={this.onChange}
      />
    );
  }

  renderSavedTextArea(label, path, name) {
    return (
      <SavedTextArea
        name={name}
        value={_.get(this, `state.founder.${path}.${name}`)}
        label={label}
        onChange={this.onChange}
      />
    );
  }

  renderSavedChoice(label, path, name, options, multi = true) {
    return <SavedChoice
      name={name}
      value={_.get(this, `state.founder.${path}.${name}`)}
      label={label}
      options={options}
      multi={multi}
      onChange={this.onChange}
    />
  }

  render() {
    if (!this.state.founder) {
      return <p>Please wait while we verify your data...</p>;
    }
    return this.renderBody();
  }
}