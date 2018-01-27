import React from 'react';
import {
  CompaniesSearchPath, CompetitorFullIndustriesOptions,
  CompetitorFundTypesOptions,
  CompetitorsLocationsPath,
  CompetitorsLocationsPathWithQuery,
  CompetitorsPath,
  FirmPath,
} from '../constants.js.erb';
import SettingsBase from './settings_base';
import {Row, Column} from 'react-foundation';
import {ffetch} from '../utils';
import Company from '../../discover/company';

const RequiredFields = {
  first_name: 'First Name',
  last_name: 'Last Name',
  email: 'Email',
  role: 'Title',
  crunchbase_id: 'Crunchbase Profile',
};

export default class CompetitorProfile extends SettingsBase {
  constructor(props) {
    super(props);
    this.state = {
      ...this.state,
      data: {
        ...props.competitor,
        ...props.competitor_fields,
      },
    };
  }

  onBlur = name => () => {
    const competitor = this.onBlurDirty(name);
    if (!competitor) {
      return;
    }
    ffetch(CompetitorsPath.id(this.props.competitor.id), 'PATCH', {
      competitor: {
        ...competitor,
        companies: _.map(competitor.companies, 'id'),
      },
    });
  };

  render() {
    const { competitor } = this.props;
    return (
      <div className="fields">
        <p className="info padded">
          These fields will be used to generate the VCWiz Profile for {competitor.name}.
          To view the external profile, click <a href={FirmPath.id(competitor.id)} target="_blank">here</a>.
        </p>
        <Row isColumn>
          {this.renderInput('name', 'Firm Name')}
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('domain', 'Firm Domain')}</Column>
          <Column large={6}>{this.renderInput('photo', 'Photo (URL)')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('twitter', 'Twitter Username')}</Column>
          <Column large={6}>{this.renderInput('facebook', 'Facebook Username')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderInput('al_id', 'AngelList ID')}</Column>
          <Column large={6}>{this.renderInput('crunchbase_id', 'Crunchbase ID')}</Column>
        </Row>
        <Row>
          <Column large={6}>{this.renderFilter('locations', 'Cities', { path: CompetitorsLocationsPath })}</Column>
          <Column large={6}>{this.renderFilter('fund_types', 'Investment Types', { options: CompetitorFundTypesOptions })}</Column>
        </Row>
        <Row>
          <Column large={6}>
            {this.renderFilter('companies', `Your investments at ${competitor.name}`,  { path: CompaniesSearchPath, optionComponent: Company })}
          </Column>
          <Column large={6}>
            {this.renderFilter('industries', `Spaces you invest in`,  { options: CompetitorFullIndustriesOptions })}
          </Column>
        </Row>
        <Row isColumn>
          {this.renderTextArea('description', `${competitor.name}'s description and investment thesis`)}
        </Row>
      </div>
    );
  }
}