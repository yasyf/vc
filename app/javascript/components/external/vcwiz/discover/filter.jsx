import React from 'react';
import { ffetch, buildQuery, withoutIndexes, filterOption } from '../global/utils';
import { defaultMenuRenderer }  from 'react-select';
import {SmallScreenSize} from '../global/constants.js.erb';
import Select from '../global/fields/select';
import { Button } from 'react-foundation';
import Highlighter from 'react-highlight-words';
import inflection from 'inflection';
import classNames from 'classnames';
import OptionFactory from './option';
import Store from '../global/store';

export default class Filter extends React.Component {
  state = {
    editing: false,
    dimensions: Store.get('dimensions', {
      width: 0,
      height: 0,
    }),
  };

  componentWillMount() {
    this.subscription = Store.subscribe('dimensions', dimensions => this.setState({dimensions}));
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

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
    const { name, input, value, meta, onInputChange } = this.props;

    const optionRenderer = o => <Highlighter
      highlightClassName='highlighter'
      searchWords={[input]}
      textToHighlight={o.label}
    />;
    const nullRenderer = () => null;
    const metaMenuRenderer = (...args) => (
      <div className="options-with-meta">
        <div className="options">{defaultMenuRenderer(...args)}</div>
        <div className="meta">{meta}</div>
      </div>
    );

    return {
      tetherClassName: "filter-select-menu",
      autoFocus: true,
      clearable: true,
      filterOption: filterOption,
      openOnFocus: true,
      closeOnSelect: false,
      onSelectResetsInput: false,
      scrollMenuIntoView: false,
      name: name,
      placeholder: 'Start typing...',
      showLabel: false,
      multi: true,
      arrowRenderer: null,
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
    const display = _.map(_.take(value, this.state.dimensions > SmallScreenSize ? 2 : 1), 'label');
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

  remoteFetch = _.debounce((q, cb) => {
    const { value, path } = this.props;
    if (!q) {
      cb(null, {options: value || []});
    } else {
      ffetch(`${path}?${buildQuery({q})}`).then(options => cb(null, {options}));
    }
  }, 300, {maxWait: 1000});

  renderRemoteSelect() {
    const { input } = this.props;
    const OptionComponent = this.props.optionComponent;
    let props = this.selectProps();
    if (OptionComponent) {
      props.optionRenderer = o => <OptionComponent input={input} {...o} />;
    }
    return this.renderSelectWithProps({loadOptions: this.remoteFetch, ...props});
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