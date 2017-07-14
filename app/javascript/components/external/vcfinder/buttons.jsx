import React from 'react';

export default class Buttons extends React.Component {
  render() {
    let { categories, current, onChange, alwaysShow } = this.props;
    if (
      !alwaysShow &&
      categories.length === 0 || (categories.length === 1 && categories[0][0] === current)
    ) {
      return null;
    }
    let buttons = categories.map(([category, name]) =>
      <button
        type="button"
        className="button category-button"
        key={category}
        onClick={() => onChange(category)}
      >
        {name} {category}
      </button>
    );
    return (
      <div className="category-buttons float-center text-center">
        {buttons}
      </div>
    );
  }
}