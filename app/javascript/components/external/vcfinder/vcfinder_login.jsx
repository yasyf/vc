import React from 'react';
import VCFinderLoginStage0 from './login/stage_0';
import VCFinderLoginStage1 from './login/stage_1';
import VCFinderLoginStage2 from './login/stage_2';
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
      case 'done':
      default:
        window.location = VCFinderPath;
        break;
    }
  }

  render() {
    return (
      <div className="text-center">
        <div>
          <h3>Welcome to VCWiz!</h3>
        </div>
        {this.renderStage()}
      </div>
    )
  }
}