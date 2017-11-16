import React from 'react';
import {ffetch, buildQuery, withoutIndexes} from '../global/utils';
import Select from '../global/fields/select';
import { Button } from 'react-foundation';
import Highlighter from 'react-highlight-words';
import inflection from 'inflection';
import classNames from 'classnames';
import OptionFactory from './option';
import menuRenderer from './menu_renderer';

export default class Filter extends React.Component {
  state = {
    editing: false,
  };

  onClick = () => {
    this.setState({editing: true});
  };

  onBlur = () => {
    this.setState({editing: false});
  };

  onChange = update => {
    const { value, name } = this.props;
    const updateValue = update[name][0];
    const index = _.findIndex(value, updateValue);
    if (index !== -1) {
      this.props.onChange({[name]: withoutIndexes(value, [index])});
    } else {
      this.props.onChange({[name]: (value || []).concat([updateValue])});
    }
  };

  selectProps() {
    const { name, label, input, value, meta, onInputChange } = this.props;

    const optionRenderer = o => <Highlighter
      highlightClassName='highlighter'
      searchWords={[input]}
      textToHighlight={o.label}
    />;
    const nullRenderer = () => null;
    const metaMenuRenderer = (...args) => (
      <div className="options-with-meta">
        <div className="options">{menuRenderer(...args)}</div>
        <div className="meta">{meta}</div>
      </div>
    );

    return {
      tetherClassName: "filter-select-menu",
      autofocus: true,
      openOnFocus: true,
      closeOnSelect: false,
      onSelectResetsInput: false,
      scrollMenuIntoView: false,
      name: name,
      placeholder: 'Start typing...',
      showLabel: false,
      multi: true,
      arrowRenderer: nullRenderer,
      menuRenderer: meta ? metaMenuRenderer : undefined,
      optionRenderer,
      optionComponent: OptionFactory(value),
      valueComponent : nullRenderer,
      onBlur: this.onBlur,
      onInputChange: v => onInputChange(name, v),
      onChange: this.onChange,
    };
  }

  renderSelected() {
    const { name, value } = this.props;
    if (!value || !value.length) {
      return null;
    }
    const display = _.map(_.take(value, 2), 'label');
    const remaining = value.length - display.length;
    return (
      <div className="selected-wrapper">
        <div className="button selected">
          {display.join(', ')}{remaining ? `, +${remaining} ${inflection.inflect('others', remaining)}` : null}
        </div>
      </div>
    );
  }

  renderEditOrSelect(props) {
    const { value } = this.props;
    const { editing } = this.state;
    if (editing) {
      return <div className="select-wrapper"><Select {...props} /></div>;
    } else {
      return (
        <div className="edit-button-wrapper">
          <Button isHollow className="edit-button" onClick={this.onClick}>
            {value && value.length ? 'Edit' : 'Add'}...
          </Button>
        </div>
      );
    }
  }

  renderSelectWithProps(props) {
    const { name, value, showLabel, label } = this.props;
    const { editing } = this.state;
    const select = (
      <div className="section">
        {this.renderSelected()}
        {this.renderEditOrSelect(props)}
      </div>
    );
    return (
      <div className={classNames('filter', {'filter-grow': editing})}>
        {showLabel ? <div className="filter-label">{label}</div> : null}
        {select}
      </div>
    );
  }

  renderLocalSelect() {
    const { options } = this.props;
    return this.renderSelectWithProps({options, ...this.selectProps()});
  }

  renderRemoteSelect() {
    const { value, input, path } = this.props;
    const OptionComponent = this.props.optionComponent;

    let loadOptions = (q) => {
      if (!q) {
        return new Promise(cb => cb({options: value || []}));
      } else {
        return ffetch(`${path}?${buildQuery({q})}`).then(options => ({options}));
      }
    };
    let props = this.selectProps();
    if (OptionComponent) {
      props.optionRenderer = o => <OptionComponent input={input} {...o} />;
    }
    return this.renderSelectWithProps({loadOptions, ...props});
  }

  renderSelect() {
    const { path } = this.props;
    if (path) {
      return this.renderRemoteSelect();
    } else {
      return this.renderLocalSelect();
    }
  }

  render() {
    return this.renderSelect();
  }
}