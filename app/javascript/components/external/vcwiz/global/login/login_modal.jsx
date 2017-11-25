import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import Input from '../fields/input';
import Filters from '../../discover/filters';
import {buildQuery, extend, ffetch, flush, merge, currentPage} from '../utils';
import {SignupPath, LoginPath, CompaniesQueryPath, StorageRestoreStateKey} from '../constants.js.erb';
import {Button, Row, Colors} from 'react-foundation';
import HiddenForm from './hidden_form';
import CompanyImage from '../../discover/company_image';
import Breadcrumb from '../breadcrumbs';
import Storage from '../storage.js.erb';
import { canUseDOM } from 'exenv';

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
      stage: props.stage || 0,
      company: {},
      hasImage: false,
      restoreState: canUseDOM ? {
        breadcrumb: Breadcrumb.peek(),
        location: currentPage(),
      } : null,
    };
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.data.domain && prevState.data.domain !== this.state.data.domain) {
      this.lookupDomain();
    }
  }

  lookupDomain() {
    ffetch(`${CompaniesQueryPath}?${buildQuery({domain: this.state.data.domain})}`).then(company => {
      if (!company) {
        return;
      }
      const { name, description, industry } = company;
      const data = merge(this.state.data, {name, description, industry});
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

  skipToLogin = () => {
    this.setState({stage: 3});
  };

  loginWithGoogle = () => {
    flush();
    Storage.set(StorageRestoreStateKey, this.state.restoreState);
    this.form.submit();
  };

  renderSubHeading() {
    const { hasImage, stage } = this.state;
    if (hasImage) {
      return null;
    }
    const skipToLogin = (stage === 0) && (
      <p className="skip">
        <a onClick={this.skipToLogin}>I already have an account</a>
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
    if (stage === 3) {
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

  renderInput(name, placeholder) {
    return (
      <Row key={name} isColumn>
        <Input
          name={name}
          placeholder={placeholder}
          value={this.state.data[name]}
          wrap={false}
          onChange={this.onChange}
        />
      </Row>
    );
  }

  renderFilters(fields) {
    return (
      <div key="filters" className="filters">
        <div className="filters-wrapper">
          <Filters
            showButton={false}
            fields={fields}
            onChange={this.onChange}
          />
        </div>
      </div>
    );
  }

  renderStage0() {
    const { company, data } = this.state;
    const continueText = (company && company.name) ? company.name : data.domain;
    return [
      <p className="info" key="text">Some Quick Info</p>,
      this.renderInput('domain', 'Your Company Domain'),
      <Button color={Colors.SUCCESS} onClick={this.nextStage} key="button">
        {this.state.data.domain ? `Continue With ${continueText}` : "I Don't Have One Yet"}
      </Button>,
    ];
  }

  renderStage1() {
    const description = this.state.data.description;
    return [
      <p className="info" key="text">What's your Startup?</p>,
      this.renderInput('name', 'Company Name'),
      this.renderInput('description', 'A short description that will help investors better understand your startup'),
      this.renderFilters(['industry', 'companies']),
      this.renderStandardButton(description && description.length > 50),
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
      <p className="info" key="text">Login with your company email address to secure your account</p>,
      <HiddenForm key="form" data={this.state.data} formRef={form => { this.form = form; }} path={this.state.path} />,
      <Button color={Colors.SUCCESS} onClick={this.loginWithGoogle} key="button">
        Login with Google
      </Button>,
    ];
  }

  renderStandardButton(isEnabled = true) {
    const { stage } = this.state;
    const enabled = isEnabled && _.every(_.map(RequiredFields[stage], f => this.state.data[f]), Boolean);
    return (
      <Row key="button" isColumn>
        <Button color={Colors.SUCCESS} onClick={enabled ? this.nextStage : undefined} isDisabled={!enabled}>
          Continue to Step {stage + 2} of {NumStages}
        </Button>
      </Row>
    );
  }

  renderBottom() {
    return (
      <div className="filters">
        <Row>
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