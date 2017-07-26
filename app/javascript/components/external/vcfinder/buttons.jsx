import React from 'react';
import classNames from 'classnames';

export default class Buttons extends React.Component {
  renderSeparator(index) {
    let { icon, categories } = this.props;

    if (!icon || index === categories.length - 1) {
      return null;
    }
    return <span className="between-button-sep"><i className={`fi-${icon}`}></i></span>;
  }

  render() {
    let { categories, current, onChange, alwaysShow, icon } = this.props;
    if (
      !alwaysShow &&
      (categories.length === 0 || (categories.length === 1 && categories[0][0] === current))
    ) {
      return null;
    }
    let buttons = categories.map(([category, name], index) =>
      <span key={category} className={icon ? 'category-button-sep' : 'category-button'}>
        <button
          type="button"
          className={classNames('button', {'hollow': category !== current, 'category-button-sep': icon})}
          onClick={() => onChange(category)}
        >
          {name}
        </button>
        {this.renderSeparator(index)}
      </span>
    );
    return (
      <div className="category-buttons float-center text-center">
        {buttons}
      </div>
    );
  }
}