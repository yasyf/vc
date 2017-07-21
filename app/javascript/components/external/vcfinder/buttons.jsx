import React from 'react';
import classNames from 'classnames';

export default class Buttons extends React.Component {
  render() {
    let { categories, current, onChange, alwaysShow } = this.props;
    if (
      !alwaysShow &&
      (categories.length === 0 || (categories.length === 1 && categories[0][0] === current))
    ) {
      return null;
    }
    let buttons = categories.map(([category, name]) =>
      <button
        type="button"
        className={classNames('button', 'category-button', {'hollow': category !== current})}
        key={category}
        onClick={() => onChange(category)}
      >
        {name}
      </button>
    );
    return (
      <div className="category-buttons float-center text-center">
        {buttons}
      </div>
    );
  }
}