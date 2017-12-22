import React from 'react';
import Input from '../global/fields/input';
import { InvestorsPath } from '../global/constants.js.erb';
import {ffetch, getDomain} from '../global/utils';
import {Button, Colors} from 'react-foundation';
import Loader from '../global/shared/loader';

export default class InvestorVerification extends React.Component {
  state = {
    loading: true,
    investor: null,
    email: null,
    success: false,
  };

  componentDidMount() {
    const { id } = this.props;
    ffetch(InvestorsPath.id(id)).then(investor => {
      this.setState({investor, loading: false});
    });
  }

  onChange = update => {
    this.setState(update);
  };

  checkEmail = () => {
    const { id } = this.props;
    const { email } = this.state;
    this.setState({loading: true});
    ffetch(InvestorsPath.resource(id, 'verify'), 'POST', {email}).then(({error}) => {
      if (error) {
        this.setState({error, loading: false});
      } else {
        this.setState({success: true, loading: false});
      }
    })
  };

  renderError() {
    const { email, investor } = this.state;
    const domain = getDomain(email);
    if (email && domain && investor.competitor.domain && domain !== investor.competitor.domain) {
      return `You must use your ${investor.competitor.domain} email`;
    }
    return null;
  }

  render() {
    const { loading, success, investor, email } = this.state;
    if (loading) {
      return (
        <div className="text-center loading">
          <Loader />
        </div>
      );
    } else if (success) {
      return (
        <div>
          <p className="success">
            Thanks! We've sent an email to <b>{email}</b> to confirm your account.
          </p>
          <p>
            Please click the link in the email to continue.
          </p>
        </div>
      );
    } else if (!investor.competitor.domain) {
      return (
        <div>
          Sorry, we aren't able to automatically create investor profiles for {investor.competitor.name} right now.
          Please <a target="_blank" href={`mailto:${SupportEmail}?subject=VCWiz Investor Profiles - ${investor.competitor.name}`}>reach out</a> so we can get you set up!
        </div>
      );
    }
    const error = this.renderError();
    return (
      <div className="verification">
        Enter your {investor.competitor.name} address to continue
        <p className="error">{error}</p>
        <Input
          name="email"
          value={email}
          onChange={this.onChange}
          placeholder={investor.competitor.domain ? `${investor.first_name.toLowerCase()}@${investor.competitor.domain}` : undefined}
        />
        <Button onClick={this.checkEmail} color={Colors.SUCCESS} isDisabled={!!error || !email || !getDomain(email)}>
          Continue
        </Button>
      </div>
    )
  }
}