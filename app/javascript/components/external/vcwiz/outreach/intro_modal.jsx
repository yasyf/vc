import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import {Button, Colors} from 'react-foundation';
import Input from '../global/fields/input';
import {extend, ffetch, fullName, getDomain} from '../global/utils';
import {IntroRequestsPath} from '../global/constants.js.erb';
import TextArea from '../global/fields/text_area';
import Store from '../global/store';
import Loader from '../global/shared/loader';

const NumStages = 5;

export default class IntroModal extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      intro: {target_investor_id: props.item.id},
      stage: 0,
      loading: false,
      preview: null,
    };
  }

  componentDidMount() {
    ffetch(`${IntroRequestsPath}?target_investor_id=${this.props.item.id}`).then(intro => {
      this.setState({
        ...intro,
        target_investor_id: this.props.item.id,
      });
    });
  }

  startPolling = () => {
    this.interval = window.setInterval(() => {
      ffetch(IntroRequestsPath.id(this.state.id)).then(({ preview_html }) => {
        if (preview_html)  {
          window.clearInterval(this.interval);
          this.setState({loading: false, preview: preview_html})
        }
      });
    }, 1000);
  };

  inputProps(name, placeholder) {
    return {
      key: name,
      name: name,
      placeholder: placeholder,
      value: this.state.intro[name],
      wrap: false,
      onChange: this.onChange,
    };
  }

  renderInput(name, placeholder) {
    return <Input {...this.inputProps(name, placeholder)} />;
  }

  renderTextArea(name, placeholder) {
    return <TextArea {...this.inputProps(name, placeholder)} />;
  }

  onChange = update => {
    const intro = extend(this.state.intro, update);
    this.setState({intro});
  };

  nextStage = () => {
    const { stage, intro } = this.state;
    const nextStage = stage + 1;
    const submit = ffetch(IntroRequestsPath, 'POST', {intro_request: intro});
    if (nextStage === 3) {
      this.setState({stage: nextStage, loading: true});
      submit.then(intro => {
        this.setState({intro});
        return ffetch(IntroRequestsPath.resource(intro.id, 'preview'), 'POST');
      }).then(this.startPolling);
    } else {
      this.setState({stage: nextStage});
      submit.then(intro => {
        this.setState({intro});
      });
    }
  };

  renderTop() {
    const { firm_name } = this.props.item;
    return (
      <div>
        <h3>Intro Request</h3>
        <p className="title">{fullName(this.props.item)} ({firm_name})</p>
      </div>
    );
  }

  renderStandardButton(disabled = false) {
    const { stage } = this.state;
    return (
      <Button color={Colors.SUCCESS} onClick={disabled ? undefined : this.nextStage} isDisabled={disabled} key="button">
        Continue to Step {stage + 2} of {NumStages}
      </Button>
    );
  }

  renderStage0() {
    const { intro } = this.state;
    const { first_name } = this.props.item;
    const hasEmail = this.props.item['email_present?'];
    return [
      <div key="welcome">
        Welcome to VCWiz Intro Requests! There's a few things we need from you.
        We'll give {first_name} a chance to review everything we collect here, and then get back to you with a response as fast as we can.
      </div>,
      hasEmail
        ? <div key="request">We'll send the intro request to {first_name}'s email on file, unless you'd prefer to specify one.</div>
        : <div key="request">We need an email for {first_name}, since we don't have one on file!</div>
      ,
      this.renderInput('email', hasEmail ? 'Default Email' : 'jane@demo.vc'),
      this.renderStandardButton(!hasEmail && !intro.email),
    ];
  }

  renderStage1() {
    const { intro } = this.state;
    const { first_name, firm_name } = this.props.item;
    const founder = Store.get('founder', {});
    return [
      <div key="info">
        Please provide a brief context blurb, which helps customize the email for this particular investor.
      </div>,
      this.renderTextArea('context', `Hey ${first_name}! My name is ${founder.first_name} and I think ${founder.primary_company.name} is a great fit for ${firm_name} because...`),
      this.renderStandardButton(!intro.context || intro.context.length < 50),
    ];
  }

  renderStage2() {
    const { intro } = this.state;
    const { primary_company } = Store.get('founder', {});
    return [
      <div key="info">
        Last one! We need a link to your pitch deck for {primary_company.name}.
      </div>,
      this.renderInput('pitch_deck', 'http://www.example.com/deck.pdf'),
      this.renderStandardButton(!intro.pitch_deck || !getDomain(intro.pitch_deck)),
    ];
  }

  renderStage3() {
    const { preview } = this.state;
    return [
      <div key="preview" className="preview" dangerouslySetInnerHTML={{ __html: preview }} />,
      this.renderStandardButton(),
    ];
  }

  renderBottom() {
    if (this.state.loading) {
      return <Loader />;
    }
    return this[`renderStage${this.state.stage}`]();
  }

  render() {
    return (
      <OverlayModal
        name="intro"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}