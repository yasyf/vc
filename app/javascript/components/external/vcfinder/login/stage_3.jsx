import React from 'react';
import {extract, ffetch} from '../utils';
import {InvestorsRecommendationsPath, TargetInvestorsPath} from '../constants.js.erb';
import InvestorRecommendations from '../investor_recommendations';

export default class VCFinderLoginStage3 extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      recommendations: null,
      done: false,
    };
  }

  componentDidMount() {
    ffetch(InvestorsRecommendationsPath).then(recommendations => this.setState({recommendations}));
  }

  onInvestorSelect = (id) => {
    ffetch(TargetInvestorsPath, 'POST', {investor: {id}})
    .then(target => this.setState({done: true, recommendations: extract(this.state.recommendations, {id})}));
  };

  renderButton() {
    let text = this.state.done ? 'Next' : 'Skip';
    return (
      <button type="button" className="button" onClick={this.props.onNextStage}>
        {text}
      </button>
    );
  }

  renderRecommendations() {
    if (this.state.recommendations.length === 0) {
      return <p>Sorry! We couldn't find any recommendations for you right now.</p>;
    }
    return (
      <InvestorRecommendations
        recommendations={this.state.recommendations}
        onSelect={this.onInvestorSelect}
      />
    );
  }

  renderBody() {
    return (
      <div>
        <p>We've got a few recommendations to check out! Feel free to add any of them to your list, or use the button at the bottom to move on.</p>
        {this.renderRecommendations()}
        {this.renderButton()}
      </div>
    );
  }

  render() {
    if (this.state.recommendations === null) {
      return <p>Please wait while we verify your data...</p>;
    }
    return this.renderBody();
  }
}