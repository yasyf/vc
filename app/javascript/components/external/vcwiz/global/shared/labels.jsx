import React from 'react';
import classNames from 'classnames';
import {withDots} from '../utils';

export default class Labels extends React.Component {
  render() {
    let { items, translate, extraClass, plain, max, block } = this.props;

    if (!items) {
      return null;
    }

    let nodes = _.take(items, max).map(i =>
      <span className={classNames({label: !plain}, extraClass)} key={i}>
        {translate[i] || i}
      </span>
    );

    if (block) {
      nodes = nodes.map((n, i) => <p key={i}>{n}</p>);
    }

    const Parent = block ? 'div' : 'span';

    if (plain) {
      return <Parent className="labels-plain">{withDots(nodes)}</Parent>;
    } else {
      return <Parent className="labels">{nodes}</Parent>;
    }
  }
}

Labels.defaultProps = {
  translate: {},
  max: 3,
};