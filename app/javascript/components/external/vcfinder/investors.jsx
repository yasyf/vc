import React from 'react';
import Investor from './investor';

export default class Investors extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      offset: 0,
    };
  }

  componentDidMount() {
    $(document.body).on('keyup.investors', this.onKeyUp);
  }

  componentWillUnmount() {
    $(document.body).off('keyup.investors', this.onKeyUp);
  }

  componentWillReceiveProps(nextProps) {
    if (this.props.investors !== nextProps.investors) {
      this.setState({offset: 0});
    }
  }

  onKeyUp = (event) => {
    switch (event.key) {
      case "n":
        this.onClick();
        break;
    }
  };

  onClick = () => {
    let offset = this.state.offset + 1;
    this.setState({offset});
    if (offset >= this.props.investors.length) {
      this.props.requestNextPage();
    }
  };

  currentInvestor() {
    return this.props.investors[this.state.offset];
  }

  render() {
    let investor = this.currentInvestor();

    if (!investor)
      return <p className="text-center">Loading...</p>;

    return (
      <div>
        <div className="investors">
          <Investor key={investor.id} {...investor} onChange={this.props.onChange} />
        </div>
        <div className="category-buttons float-center text-center">
          <button type="button" className="button" onClick={this.onClick}>
            Next
          </button>
        </div>
      </div>
    );
  }
}