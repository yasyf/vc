import React from 'react';
import moment from 'moment';
import TextCell from './text_cell';

export default class DatetimeCell extends TextCell {
  processRow(props, row) {
    let datetime = _.get(row, props.columnKey);
    let value = datetime && moment(datetime).fromNow();
    return {value};
  }
}