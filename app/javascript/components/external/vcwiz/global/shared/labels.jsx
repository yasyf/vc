import React from 'react';
import classNames from 'classnames';
import {withDots} from '../utils';

export default class Labels extends React.Component {
  render() {
    let {items, translate, extraClass, plain} = this.props;

    if (!items) {
      return null;
    }

    let nodes = items.map(i =>
      <span className={classNames({label: !plain}, extraClass)} key={i}>
        {translate[i] || i}
      </span>
    );
    if (plain) {
      return <span className="labels-plain">{withDots(nodes)}</span>;
    } else {
      return <span className="labels">{nodes}</span>;
    }
  }
}

Labels.defaultProps = {
  translate: {},
};