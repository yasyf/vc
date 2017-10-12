import React from 'react';
import TextCell from './text_cell';
import Company from '../../discover/company';

export default class CompanyCell extends TextCell {
  renderComany() {
    let { value } = this.state;
    return value ? <Company {...value} lines={2} /> : null;
  }

  renderValue() {
    return (
      <div className='company-cell'>
        {this.renderComany()}
      </div>
    )
  }
}