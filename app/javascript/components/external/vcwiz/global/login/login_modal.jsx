import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import Input from '../fields/input';
import Filters from '../../discover/filters';
import {buildQuery, extend, ffetch, merge} from '../utils';
import {SignupPath, CompaniesQueryPath} from '../constants.js.erb';
import {Button, Row, Colors} from 'react-foundation';
import HiddenForm from './hidden_form';
import CompanyImage from '../../discover/company_image';

const RequiredFields = [
  [],
  ['name', 'description', 'industry'],
  ['fund_type', 'location'],
  [],
];
const NumStages = RequiredFields.length;

export default class LoginModal extends React.Component {
  state = {
    data: {},
    stage: 0,
    company: {},
    hasImage: false,
  };

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
    this.setState({stage: this.state.stage + 1});
  };

  loginWithGoogle= () => {
    this.form.submit();
  };

  renderSubHeading() {
    const { hasImage } = this.state;
    if (hasImage) {
      return null;
    }
    return (
      <div className="muted">
        Help us personalize your search results and provide you with introductions to VCs.
      </div>
    );
  }

  renderTop() {
    const { data, hasImage } = this.state;
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

  renderFilters(sizes) {
    return (
      <Filters
        key="filters"
        showButton={false}
        showLabels={'present'}
        sizes={sizes}
        onChange={this.onChange}
      />
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
    return [
      <p className="info" key="text">Your Startup</p>,
      this.renderInput('name', 'Company Name'),
      this.renderInput('description', 'Description (may be shown to investors)'),
      this.renderFilters({industry: -1, companies: -1}),
      this.renderStandardButton(),
    ];
  }

  renderStage2() {
    return [
      <p className="info" key="text">Your Ideal Investor</p>,
      this.renderFilters({fund_type: -1, location: -1}),
      this.renderStandardButton(),
    ];
  }

  renderStage3() {
    return [
      <p className="info" key="text">Login with your company email address to secure your account</p>,
      <HiddenForm key="form" data={this.state.data} formRef={form => { this.form = form; }} path={SignupPath} />,
      <Button color={Colors.SUCCESS} onClick={this.loginWithGoogle} key="button">
        Login with Google
      </Button>,
    ];
  }

  renderStandardButton() {
    const { stage } = this.state;
    const enabled = _.every(_.map(RequiredFields[stage], f => this.state.data[f]), Boolean);
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