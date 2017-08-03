import React from 'react';
import { ToastContainer, toast } from 'react-toastify';
import Search from './search.jsx';
import TargetInvestors from './target_investors';
import {emplace, ffetch, isDRF, pluckSort, flash, fullName} from './utils';
import {TargetInvestorsPath, TargetInvestorStageKeys, TargetInvestorStages} from './constants.js.erb';

export default class VCFinder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      targets: [],
      stage: TargetInvestorStageKeys[0],
      selected: null,
    };
  }

  componentDidMount() {
    ffetch(TargetInvestorsPath)
    .then(targets => this.setState({
      targets,
      stage: this.defaultStage(targets),
      open: _.get(targets, ['0', 'id']),
    }));
  }

  allStages(targets) {
    return pluckSort(targets, 'stage', TargetInvestorStageKeys);;
  }

  defaultStage(targets) {
    let stages = this.allStages(targets);
    return stages[0] || TargetInvestorStageKeys[0];
  }

  onNewTarget = (update) => {
    ffetch(TargetInvestorsPath, 'POST', update).then(target => {
      let targets = this.state.targets.concat([target]);
      this.setState({
        selected: targets.length - 1,
        targets,
      });
    });
  };
  
  onInvestorSelect = (investor) => {
    ffetch(TargetInvestorsPath, 'POST', {investor: {id: investor.id}})
    .then(target => {
      flash(`Now tracking ${fullName(target)}!`);
      let targets = this.state.targets.concat([target]);
      this.setState({
        stage: TargetInvestorStageKeys[0],
        selected: targets.length - 1,
        targets,
      })
    });
  };

  onTargetChange = (id, change) => {
    ffetch(TargetInvestorsPath.id(id), 'PATCH', {target_investor: change})
    .then(target => {
      let [targets, i] = emplace(this.state.targets, target);
      if (change.stage) {
        flash(`${fullName(target)} moved to ${TargetInvestorStages[change.stage]}`);
      }
      this.setState({targets, selected: i});
    })
  };

  onStageChange = (stage) => {
    this.setState({stage});
  };

  renderDRFWelcome() {
    if (!isDRF()) {
      return null;
    }
    return "Since you're a DRF founder, I can also help facilitate intros to other investors through First Round's network."
  }

  renderHelp() {
    return (
      <div className="vcwiz-info">
        <p>
          Welcome to the VCWiz investor outreach organizer!
          I'm here to help you find relevant investors, and coordinate your outreach.
          {' '}
          {this.renderDRFWelcome()}
        </p>
        <p>
          Use the search bar above to add all your target investors.
          We split your investors up by priority tiers, and give you simple actions to track your outreach with each one.
          Click on an investor's name to view or change their status.
        </p>
      </div>
    );
  }

  render() {
    return (
      <div>
        <Search onSelect={this.onInvestorSelect} />
        {this.renderHelp()}
        <TargetInvestors
          targets={this.state.targets}
          stage={this.state.stage}
          selected={this.state.selected}
          onTargetChange={this.onTargetChange}
          onNewTarget={this.onNewTarget}
          onStageChange={this.onStageChange}
        />
        <ToastContainer position={toast.POSITION.BOTTOM_LEFT} autoClose={4000} />
      </div>
    );
  }
}