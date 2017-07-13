import React from 'react';
import SavedText from './saved_text';

export default class SavedTextArea extends SavedText {
  renderInput() {
    return (
      <textarea {...this.inputProps()} />
    );
  }
  }