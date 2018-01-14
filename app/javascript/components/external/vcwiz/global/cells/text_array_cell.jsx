import React from 'react';
import TextCell from './text_cell';

export default class TextArrayCell extends TextCell {
  processRow(props, row) {
    let values = props.data;
    if (!values || !values.length) {
      return {value: ''};
    }
    if (props.translate) {
      values = _.compact(values.map(v => props.translate[v]));
    }

    let value;
    if (props.limit && values.length > props.limit) {
      value = `${_.take(values, props.limit).join(', ')}, +${values.length - props.limit}`;
    } else {
      value = values.length ? values.join(', ') : '';
    }
    return {value};
  };
}