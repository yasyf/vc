import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import Store from '../global/store';
import { MagnifyingGlassImagePath, MeetingImagePath } from '../global/constants.js.erb';
import {Row, Column} from 'react-foundation';
import Slider from 'react-slick';
import Tutorial from './tutorial';

export default class WelcomeModal extends React.Component {
  state = {
    moved: false
  };

  onMouseMove = () => {
    clearTimeout(this.timeout);
    this.setState({moved: true});
  };

  beforeChange = () => {
    clearTimeout(this.timeout);
    this.setState({moved: false});
    this.timeout = setTimeout(() => {
      this.setState({moved: true});
    }, 3 * 1000);
  };

  renderTop() {
    const { first_name } = Store.get('founder', {});
    return <h3>Welcome to <span className="highlight">VCWiz</span> {first_name}!</h3>;
  }

  renderSlide1() {
    return (
      <div className="slide-1">
        <h3>We're so excited to help you on your fundraising journey!</h3>
        <Row>
          <Column large={6}>
            <div className="large-icon">
              <h4><span className="highlight">Discover</span> potential investors and get the inside scoop</h4>
              <img className="reversed" src={MagnifyingGlassImagePath} />
            </div>
          </Column>
          <Column large={6}>
            <div className="large-icon">
              <h4><span className="highlight">Track</span> your relationships with new and old investors</h4>
              <img src={MeetingImagePath} />
            </div>
          </Column>
        </Row>
      </div>
    )
  }

  renderSlide2() {
    const { moved } = this.state;
    return (
      <div className="slide-2" onMouseMove={this.onMouseMove}>
        <h3>Discover</h3>
        <div className="tutorials-wrapper">
          <Tutorial n={1} playing={moved} caption="Select your filters or search terms" />
          <div className="caret" />
          <Tutorial n={2} playing={moved} caption="Explore your personalized results and select interesting firms" />
          <div className="caret" />
          <Tutorial n={3} playing={moved} caption="Learn more about individual investors and add them to your wishlist" />
        </div>
      </div>
    )
  }

  renderSlide3() {
    const { moved } = this.state;
    return (
      <div className="slide-3" onMouseMove={this.onMouseMove}>
        <h3>Track</h3>
        <div className="tutorials-wrapper">
          <Tutorial n={4} playing={moved} caption="Keep track of your investor outreach with a glance" />
          <div className="caret" />
          <Tutorial n={5} playing={moved} caption="Have your tracker automatically update and show mutual connections with email integration" />
          <div className="caret" />
          <Tutorial n={6} playing={moved} caption="Organize your fundraising process" />
        </div>
      </div>
    )
  }

  renderBottom() {
    return (
      <Slider dots={true} lazyLoad={false} infinite={false} adaptiveHeight={false} beforeChange={this.beforeChange}>
        {this.renderSlide1()}
        {this.renderSlide2()}
        {this.renderSlide3()}
      </Slider>
    );
  }

  render() {
    return (
      <OverlayModal
        name="welcome"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}