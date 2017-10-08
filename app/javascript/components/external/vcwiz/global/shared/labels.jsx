import React from 'react';
import classNames from 'classnames';

export default class Labels extends React.Component {
  render() {
    let {items, translate, extraClass} = this.props;

    if (!items) {
      return null;
    }

    let nodes = items.map(i =>
      <span className={classNames('label', extraClass)} key={i}>
        {translate[i] || i}
      </span>
    );
    return <span className="labels">{nodes}</span>;
  }
}

Labels.defaultProps = {
  translate: {},
};