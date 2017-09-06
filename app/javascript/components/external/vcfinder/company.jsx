import React from 'react';
import Industries from './shared/industries';

export default class Company extends React.Component {
  render() {
    let {name, description, industry, cb_url, al_url, website} = this.props.company;
    return (
      <div className="pull-right">
        <h6>
          <a href={website || al_url || cb_url} target="_blank">{name}</a>
          {' '}
          <Industries industry={industry} extraClass="small"/>
        </h6>
        <p><small>{description}</small></p>
      </div>
    );
  }
}