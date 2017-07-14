import React from 'react';

export default class InvestorHead extends React.Component {
  renderDescription() {
    let { description, competitor } = this.props;

    return (
      <div className="card-section">
        <p className="faded">
          {competitor.description}
          {' '}
          {description}
        </p>
      </div>
    );
  }

  renderBadge() {
    if (!this.props.badge)
      return null;
    return <span className="right-badge">{this.props.badge}</span>;
  }

  render() {
    let { first_name, last_name, role, competitor } = this.props;
    return (
      <div>
        <div className="card-divider">
          <strong>{first_name} {last_name}</strong>
          &nbsp;
          <em>({role}{role ? ', ' : ''}{competitor.name})</em>
          {this.renderBadge()}
        </div>
        {this.renderDescription()}
      </div>
    );
  }
}