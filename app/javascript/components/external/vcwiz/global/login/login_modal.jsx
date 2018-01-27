import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import Input from '../fields/input';
import Filters from '../../discover/filters';
import {
  buildQuery, extend, ffetch, flush, merge, currentPage,
  getDomain, toOptions, preloadImages,
} from '../utils';
import {
  SignupPath,
  LoginPath,
  CompaniesQueryPath,
  StorageRestoreStateKey,
  CompetitorIndustries,
  GoogleLoginImagePath,
  GoogleLoginLightImagePath,
  InvestorsRootPath,
} from '../constants.js.erb';
import {Button, Row, Column, Colors} from 'react-foundation';
import HiddenForm from './hidden_form';
import CompanyImage from '../../discover/company_image';
import Breadcrumb from '../breadcrumbs';
import {SessionStorage} from '../storage.js.erb';
import { canUseDOM } from 'exenv';
import TextArea from '../fields/text_area';
import classNames from 'classnames';

const RequiredFields = [
  [],
  ['name', 'description', 'industry'],
  ['fund_type', 'location'],
  [],
];
const NumStages = RequiredFields.length;

export default class LoginModal extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      path: LoginPath,
      data: {},
      stage: props.stage,
      company: {},
      hasImage: false,
      restoreState: canUseDOM ? {
        breadcrumb: Breadcrumb.peek(),
        location: currentPage(),
      } : null,
    };
  }

  componentDidMount() {
    this.preloadImages();
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.data.domain && prevState.data.domain !== this.state.data.domain) {
      this.lookupDomain();
    }
  }

  preloadImages() {
    if (!canUseDOM) {
      return;
    }
    preloadImages([GoogleLoginImagePath, GoogleLoginLightImagePath]);
  }

  lookupDomain() {
    const domain = getDomain(this.state.data.domain, false);
    if (!domain) {
      return;
    }
    ffetch(`${CompaniesQueryPath}?${buildQuery({domain})}`).then(company => {
      if (!company) {
        if (!_.isEmpty(this.state.company)) {
          this.setState({company: {}, data: {}});
        }
        return;
      }
      const { name, description, industry } = company;
      const industryOptions = toOptions(industry || [], CompetitorIndustries);
      const data = merge(this.state.data, {name, description, industry: industryOptions});
      this.setState({company, data});
    });
  }

  onHasImage = () => {
    this.setState({hasImage: true});
  };

  onImageError = () => {
    this.setState({hasImage: false});
  };

  onChange = update => {
    const data = extend(this.state.data, update);
    this.setState({data});
  };

  nextStage = () => {
    this.setState({stage: this.state.stage + 1, path: SignupPath});
  };

  beforeLogin() {
    flush();
    SessionStorage.set(StorageRestoreStateKey, this.state.restoreState);
  }

  loginWithGoogle = () => {
    this.beforeLogin();
    this.form.submit();
  };

  loginWithGoogleInbox = () => {
    this.beforeLogin();
    const data = extend(this.state.data, {enable_scanner: true});
    this.setState({data}, () => this.form.submit());
  };

  renderSubHeading() {
    const { hasImage, stage } = this.state;
    if (hasImage) {
      return null;
    }
    const skipToLogin = (stage === 0) && (
      <p className="skip">
        <a href={InvestorsRootPath}>I'm an investor</a>
      </p>
    );
    return (
      <div>
        {skipToLogin || null}
        <p className="muted">
          Help us personalize your search results and provide you with introductions to VCs.
        </p>
      </div>
    );
  }

  renderTop() {
    const { data, hasImage, stage } = this.state;
    if (stage >= 3) {
      return (
        <div className="title">
          <h3>Login To VCWiz</h3>
          <div className="muted">
            VCWiz uses your email address to verify your account.
          </div>
        </div>
      );
    } else {
      return (
        <div className="title">
          <h3>Sign Up For VCWiz</h3>
          <CompanyImage
            fallback={null}
            domain={data.domain}
            size={150}
            relaxHeight={true}
            style={hasImage ? undefined : {display: 'none'}}
            onLoad={this.onHasImage}
            onError={this.onImageError}
          />
          {this.renderSubHeading()}
        </div>
      );
    }
  }

  inputProps(name, placeholder) {
    return {
      name: name,
      placeholder: placeholder,
      value: this.state.data[name],
      wrap: false,
      onChange: this.onChange,
    };
  }

  renderInput(name, placeholder, debounced = false) {
    return (
      <Row key={name} isColumn>
        <Input {...this.inputProps(name, placeholder)} debounced={debounced} />
      </Row>
    );
  }

  renderTextArea(name, placeholder) {
    return (
      <Row key={name} isColumn>
        <TextArea {...this.inputProps(name, placeholder)} />
      </Row>
    );
  }

  renderFilters(fields) {
    return (
      <div key="filters" className="filters">
        <div className="filters-wrapper">
          <Filters
            initialFilters={_.pick(this.state.data, fields)}
            showButton={false}
            fields={fields}
            onChange={this.onChange}
          />
        </div>
      </div>
    );
  }

  renderGoogleForm() {
    return <HiddenForm key="form" data={this.state.data} formRef={form => { this.form = form; }} path={this.state.path} />;
  }

  renderGoogleButton(onClick, light = false) {
    return (
      <div key="button" className="google-button">
        <Button className={classNames('google', {light: light})} onClick={onClick}>
        </Button>
      </div>
    );
  }

  renderStage0() {
    const { company, data } = this.state;
    const continueText = (company && company.name) ? company.name : data.domain;
    return [
      <p className="info" key="text">Some Quick Info</p>,
      this.renderInput('domain', 'Your Company Website', true),
      <Button color={Colors.SUCCESS} onClick={this.nextStage} key="button">
        {this.state.data.domain ? `Continue With ${continueText}` : "I Don't Have One Yet"}
      </Button>,
    ];
  }

  renderStage1() {
    const description = this.state.data.description;
    const charsRemaining = (description && description.length < 50) && `Your description needs ${50 - description.length} more characters.`;
    const charsOver = (description && description.length >= 600) && `Your description needs ${description.length - 600} fewer characters.`;
    return [
      <p className="info" key="text">What's your Startup?</p>,
      this.renderInput('name', 'Company Name'),
      this.renderTextArea('description', 'A short description that will help investors better understand your startup'),
      this.renderFilters(['industry', 'companies']),
      this.renderStandardButton(description && description.length > 50 && description.length < 600, charsRemaining || charsOver),
    ];
  }

  renderStage2() {
    return [
      <p className="info" key="text">Who's your ideal investor?</p>,
      this.renderFilters(['fund_type', 'location']),
      this.renderStandardButton(),
    ];
  }

  renderStage3() {
    return [
      <div key="text" className="permission-info">
        <p>
          Last step! To verify your email address, we need you to log in with your Google account.
        </p>
        <p>
          You also have the option to enable VCWiz Link, which will help you figure out your intro path to any VC, and sync your conversations with investors to VCWiz.
        </p>
        <p>
          Here is how VCWiz will and won't use your data.
        </p>
        <ol>
          <li>No human will <b>ever</b> have access to your data.</li>
          <li>We will <b>never</b> use your individual conversation data for anything other than your personal dashboard and analytics.</li>
          <li>We will <b>only</b> use aggregate data to look at high level trends.</li>
          <li>If you give us inbox access, we will <b>only</b> process email metadata (to, from, and subject)&mdash;<b>never</b> any content.</li>
        </ol>
      </div>,
      this.renderGoogleForm(),
      <Row key="login-with-inbox" className="full-width">
        <Column large={6}>
          <p className="info">Login without VCWiz Link</p>
          {this.renderGoogleButton(this.loginWithGoogle, true)}
        </Column>
        <Column large={6}>
          <p className="info">Login and enable VCWiz Link</p>
          {this.renderGoogleButton(this.loginWithGoogleInbox)}
        </Column>
      </Row>,
    ];
  }

  renderStage4() {
    return [
      <p className="login-info" key="info">Login with your company email address to secure your account.</p>,
      <p className="login-sub-info" key="subinfo">You will be redirected to Google to complete your login.</p>,
      this.renderGoogleForm(),
      this.renderGoogleButton(this.loginWithGoogle),
    ];
  }

  renderStandardButton(isEnabled = true, text = null) {
    const { stage } = this.state;
    const enabled = isEnabled && _.every(_.map(RequiredFields[stage], f => this.state.data[f]), Boolean);
    return (
      <Row key="button" isColumn>
        <Button color={Colors.SUCCESS} onClick={enabled ? this.nextStage : undefined} isDisabled={!enabled}>
          {text || `Continue to Step ${stage + 2} of ${NumStages}`}
        </Button>
      </Row>
    );
  }

  renderBottom() {
    const { stage } = this.state;
    return (
      <div className="filters">
        <Row className={classNames({narrow: stage < 3, padded: stage >= 3})}>
          {this[`renderStage${this.state.stage}`]()}
        </Row>
      </div>
    )
  }

  render() {
    return (
      <OverlayModal
        name="login"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}