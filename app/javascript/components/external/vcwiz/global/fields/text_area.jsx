import React from 'react';
import Input from './input';

export default class TextArea extends Input {
  renderInput() {
    return (
      <textarea key="input" {...this.inputProps()} />
    );
  }
}