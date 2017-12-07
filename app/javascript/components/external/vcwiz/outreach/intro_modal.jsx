import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import {Button, Colors} from 'react-foundation';
import Input from '../global/fields/input';
import {extend, ffetch, fullName, getDomain} from '../global/utils';
import {IntroRequestsPath, SupportEmail} from '../global/constants.js.erb';
import TextArea from '../global/fields/text_area';
import Store from '../global/store';
import Actions from '../global/actions';
import PlaceholderInput from '../global/fields/placeholder_input';
import StandardLoader from '../global/shared/standard_loader';

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

  componentWillUnmount() {
    window.clearInterval(this.interval);
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

  renderPlaceholderInput(name, placeholder) {
    return <PlaceholderInput {...this.inputProps(name, placeholder)} />;
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

  submit = () => {
    const { intro } = this.state;
    ffetch(IntroRequestsPath.resource(intro.id, 'confirm'), 'POST').then(() => {
      Actions.trigger('refreshFounder');
    });
    this.props.onClose();
  };

  renderTop() {
    const { firm_name } = this.props.item;
    return (
      <div>
        <h2>Intro Request</h2>
        <h4>{fullName(this.props.item)} ({firm_name})</h4>
      </div>
    );
  }

  renderStandardButton(disabled = false, text = null) {
    const { stage } = this.state;
    return (
      <Button color={Colors.SUCCESS} onClick={disabled ? undefined : this.nextStage} isDisabled={disabled} key="button">
        {text || `Continue to Step ${stage + 2} of ${NumStages}`}
      </Button>
    );
  }

  renderStage0() {
    const { intro } = this.state;
    const { first_name } = this.props.item;
    const hasEmail = this.props.item['email_present?'];
    return [
      <p key="welcome">
        Welcome to VCWiz Intro Requests! There's a few things we need from you.
        We'll give {first_name} a chance to review everything we collect here, and then get back to you with a response as fast as we can.
      </p>,
      <p key="request">
        {
          hasEmail
            ? `We'll send the intro request to ${first_name}'s email on file, unless you'd prefer to specify one:`
            : `We need an email for ${first_name}, since we don't have one on file:`
        }
        {' '}
        {this.renderPlaceholderInput('email', hasEmail ? '<default email>' : '<enter email>')}
      </p>,
      this.renderStandardButton(!hasEmail && !intro.email),
    ];
  }

  renderStage1() {
    const { intro } = this.state;
    const { first_name, firm_name } = this.props.item;
    const founder = Store.get('founder', {});
    const charsRemaining = (intro.context && intro.context.length < 50) && `Your context needs ${50 - intro.context.length} more characters.`;
    return [
      <p key="info">
        Please provide a brief context blurb, which helps customize the email for this particular investor.
      </p>,
      this.renderTextArea('context', `Hey ${first_name}! My name is ${founder.first_name} and I think ${founder.primary_company.name} is a great fit for ${firm_name} because...`),
      this.renderStandardButton(!intro.context || intro.context.length < 50, charsRemaining),
    ];
  }

  renderStage2() {
    const { intro } = this.state;
    const { firm_name } = this.props.item;
    const { primary_company } = Store.get('founder', {});
    return [
      <p key="info">
        Last one!
        We need a link to your pitch deck for {primary_company.name}.
        You should customize this deck for {firm_name}.
        We recommend using a Dropbox or Google Drive link.
      </p>,
      this.renderInput('pitch_deck', 'http://www.example.com/deck.pdf'),
      this.renderStandardButton(!intro.pitch_deck || !getDomain(intro.pitch_deck)),
    ];
  }

  renderStage3() {
    const { preview } = this.state;
    const { primary_company } = Store.get('founder', {});
    return [
      <p key="info">
        Please check out the below preview, and hit send if you're happy with it!
        <br />
        We currently don't allow any customization,
        but you can add and remove fields on the settings page to change what's included.
      </p>,
      <div key="preview" className="preview" dangerouslySetInnerHTML={{ __html: preview }} />,
      <Button color={Colors.SUCCESS} onClick={this.submit} key="button">
        Send!
      </Button>,
    ];
  }

  renderBottom() {
    if (this.state.loading) {
      return <StandardLoader text="Loading Preview" />;
    }
    return <div className="intro-form">{this[`renderStage${this.state.stage}`]()}</div>;
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