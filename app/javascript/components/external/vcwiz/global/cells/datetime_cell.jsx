import React from 'react';
import moment from 'moment';
import TextCell from './text_cell';

export default class DatetimeCell extends TextCell {
  processRow(props, row) {
    const datetime = props.data;
    const value = datetime && moment(datetime).fromNow();
    return {value};
  }
}