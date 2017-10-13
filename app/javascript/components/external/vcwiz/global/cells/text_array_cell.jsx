import React from 'react';
import TextCell from './text_cell';

export default class TextArrayCell extends TextCell {
  processRow(props, row) {
    console.log(props, row);
    let values = row[props.columnKey];
    if (!values || !values.length) {
      return {value: ''};
    }
    if (props.translate) {
      values = _.compact(values.map(v => props.translate[v]));
    }
    let value = values.length ? values.join(', ') : '';
    return {value};
  };
}