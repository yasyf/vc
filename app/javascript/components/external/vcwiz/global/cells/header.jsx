import React from 'react';
import {Cell} from 'fixed-data-table-2';
import classNames from 'classnames';
import { SortDirection } from '../constants.js.erb';
import {nullOrUndef} from '../utils';

export default class Header extends React.Component {
  onClick = () => {
    const { onSort, sort, columnKey } = this.props;
    switch (sort[columnKey]) {
      case SortDirection.Asc:
        onSort(columnKey, SortDirection.Desc);
        break;
      case SortDirection.Desc:
        onSort(columnKey, SortDirection.Natural);
        break;
      case SortDirection.Natural:
        onSort(columnKey, SortDirection.Asc);
        break;
    }
  };

  renderArrow() {
    const { sort, columnKey } = this.props;
    switch (sort[columnKey]) {
      case SortDirection.Asc:
        return "▲";
      case SortDirection.Desc:
        return "▼";
      case SortDirection.Natural:
        return <span className="sort">↕</span>;
      default:
        return null;
    }
  }

  render() {
    const { sort, columnKey, name } = this.props;
    const sortable = !nullOrUndef(sort[columnKey]);
    return (
      <Cell className={classNames('header', {sortable: sortable})} onClick={sortable ? this.onClick : undefined}>
        {name} {this.renderArrow()}
      </Cell>
    );
  }
}