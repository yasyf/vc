import React from 'react';
import VCWiz  from '../vcwiz';
import SettingsBase from '../global/settings/settings_base';
import { InvestorsRootPath, InvestorsUpdateContactsPath, InvestorsPath } from '../global/constants.js.erb';
import { Row, Column, Button, Colors } from 'react-foundation';
import HiddenForm from '../global/login/hidden_form';
import {ffetch} from '../global/utils';
import Partner from './partner';

export default class InvestorSettings extends SettingsBase {
  static defaultProps = {
    showLabels: false,
  };

  constructor(props) {
    super(props);

    this.state = {
      contacts: props.contacts,
    };
  }

  onRemove = id => () => {
    ffetch(InvestorsPath.id(id), 'PATCH', {investor: {hidden: true}});
    this.setState({contacts: _.reject(this.state.contacts, {id})});
  };

  onSubmit = () => {
    this.form.submit();
  };

  renderTop() {
    return <h3>Other Investors at {this.props.investor.competitor.name}</h3>;
  }

  renderInvestor = (investor) => {
    const { competitor } = this.props.investor;
    const { id } = investor;
    return (
      <Row key={id.toString()}>
        <Column large={7}>
          <Partner investor={investor} competitor={competitor} onRemove={this.onRemove} />
        </Column>
        <Column large={5}>
          {this.renderInput(id.toString(), `${investor.first_name}'s ${competitor.domain} email`)}
        </Column>
      </Row>
    );
  };

  renderBottom() {
    const { investor } = this.props;
    const { contacts } = this.state;
    const { competitor } = investor;
    return (
      <div className="fields">
        <p className="info">
          To present the most accurate information about {competitor.name} to founders, you can invite your colleagues to verify their VCWiz profiles.
          If any of these people no longer work at {competitor.name}, click the <span className="red">x</span>.
        </p>
        <HiddenForm data={{emails: JSON.stringify(this.state.data)}} formRef={form => { this.form = form; }} path={InvestorsUpdateContactsPath} />
        <div className="contacts">{contacts.map(this.renderInvestor)}</div>
        <Row isColumn className="button-wrapper">
          <Button onClick={this.onSubmit} color={Colors.SUCCESS}>
            {_.isEmpty(this.state.data) ? 'Skip' : 'Next'}
          </Button>
        </Row>
      </div>
    );
  }

  render() {
    return (
      <VCWiz
        page="investor_contacts"
        subtitle={`${this.props.investor.competitor.name} Investor Portal`}
        header={this.renderTop()}
        body={this.renderBottom()}
        showLogin={false}
        logoLinkPath={InvestorsRootPath}
      />
    );
  }
}
