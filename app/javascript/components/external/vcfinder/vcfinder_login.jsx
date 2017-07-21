import React from 'react';
import VCFinderLoginStage0 from './login/stage_0';
import VCFinderLoginStage1 from './login/stage_1';
import VCFinderLoginStage2 from './login/stage_2';
import VCFinderLoginStage3 from './login/stage_3';
import {VCFinderPath, LoginStages} from './constants.js.erb';

export default class VCFinderLogin extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      stage: props.stage,
    };
  }

  onNextStage = () => {
    this.setState({stage: LoginStages[this.state.stage] + 1})
  };

  renderStage() {
    switch (this.state.stage) {
      case 0:
      case 'start':
        return <VCFinderLoginStage0 />;
        break;
      case 1:
      case 'company':
        return <VCFinderLoginStage1 onNextStage={this.onNextStage} />;
        break;
      case 2:
      case 'profile':
        return <VCFinderLoginStage2 onNextStage={this.onNextStage} />;
        break;
      case 3:
      case 'suggest':
        return <VCFinderLoginStage3 onNextStage={this.onNextStage} />;
        break;
      case 4:
      case 'done':
      default:
        window.location = VCFinderPath;
        break;
    }
  }

  renderWelcome() {
    switch (this.state.stage) {
      case 0:
      case 'start':
        return 'Welcome to VCWiz!';
        break;
      case 1:
      case 'company':
        return `Welcome to VCWiz, ${gon.founder.first_name}!`;
        break;
      default:
        return 'VCWiz';
        break;
    }
  }

  render() {
    return (
      <div className="text-center">
        <div>
          <h3>{this.renderWelcome()}</h3>
        </div>
        {this.renderStage()}
      </div>
    )
  }
}