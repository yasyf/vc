import React from 'react';
import {csrfToken} from '../utils';

export default class HiddenForm extends React.Component {
  render() {
    const { data, path, formRef } = this.props;
    const inputs = Object.entries(data).map(([k, v]) =>
      <input type="hidden" key={k} name={k} value={v} />
    );
    return (
      <form method="POST" action={path} ref={formRef}>
        {inputs}
        <input type="hidden" name="authenticity_token" value={csrfToken()} />
      </form>
    );
  }
}