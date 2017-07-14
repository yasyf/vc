import React from 'react';
import Buttons from './buttons';
import Investors from './investors';
import {emplace, ffetch} from './utils';
import { INVESTOR, InvestorsPath } from './constants.js.erb';

export default class VCFinderAdmin extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      type: INVESTOR,
      data: [],
      page: 0,
    };
  }

  dataPath(type = null) {
    return (type || this.state.type) === INVESTOR ? InvestorsPath : null;
  }

  fetchData(type = null, page = null) {
    type = type || this.state.type;
    page = page || this.state.page;
    ffetch(`${this.dataPath(type)}?page=${page}`).then(data => this.setState({data, type, page}));
  }

  componentDidMount() {
    this.fetchData();
  }

  onDatumChange = (id, change) => {
    ffetch(`${this.dataPath()}/${id}`, 'PATCH', {[this.state.type]: change})
      .then(target => {
        let targets = emplace(this.state.targets, target);
        this.setState({targets});
      });
  };

  requestNextPage = () => {
    this.fetchData(null, this.state.page + 1);
  };

  onTypeChange = (type) => {
    this.fetchData(type);
  };

  renderTypeButtons() {
    let buttons = [[INVESTOR, 'Investors']];
    return (
      <Buttons
        categories={buttons}
        current={this.state.type}
        onChange={this.onTypeChange}
      />
    );
  }

  renderInvestor() {
    return <Investors
      investors={this.state.data}
      onChange={this.onDatumChange}
      requestNextPage={this.requestNextPage}
    />
  }

  renderMain() {
    switch (this.state.type) {
      case INVESTOR:
        return this.renderInvestor();
        break;
    }
  }

  render() {
    return (
      <div>
        <h3 className="text-center">VCWiz Admin</h3>
        <h4 className="text-center">Page {this.state.page + 1}</h4>
        <p className="text-center">Fill out as much as you can, and click next.</p>
        {this.renderTypeButtons()}
        {this.renderMain()}
      </div>
    );
  }
}