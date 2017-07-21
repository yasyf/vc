import React from 'react';
import InvestorRecommendation from './investor_recommendation';

export default class InvestorRecommendations extends React.Component {

  onClick = () => {
    let offset = this.state.offset + 1;
    this.setState({offset});
    if (offset >= this.props.investors.length) {
      this.props.requestNextPage();
    }
  };

  renderRecommendations() {
    return this.props.recommendations.map(
      rec => <InvestorRecommendation key={rec.id} {...rec} onSelect={this.props.onSelect} />
    );
  }

  render() {
    if (!this.props.recommendations)
      return <p className="text-center">Loading...</p>;

    return (
      <div className="investors">
        {this.renderRecommendations()}
      </div>
    );
  }
}