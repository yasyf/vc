import React from 'react';
import { SortDirection } from '../constants.js.erb';
import {fromTableSD} from '../utils';

function renderArrow(sortDirect) {
  switch (fromTableSD(sortDirect)) {
    case SortDirection.Asc:
      return <span key="sort" className="arrow">▲</span>;
    case SortDirection.Desc:
      return <span key="sort" className="arrow">▼</span>;
    case SortDirection.Natural:
      return <span key="sort" className="sort">↕</span>;
    default:
      return null;
  }
}

const tableHeader = ({ dataKey, label, sortBy, sortDirection }) => ([
  <span
    className="ReactVirtualized__Table__headerTruncatedText"
    key="label"
    title={label}
  >
    {label}
  </span>,
  renderArrow(sortBy === dataKey ? sortDirection : null),
]);

export default tableHeader;