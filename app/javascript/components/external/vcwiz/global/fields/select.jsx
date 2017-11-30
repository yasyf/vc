import React from 'react';
import ReactSelect  from 'react-select';
import Input from './input';
import Tether from '../shared/tether';

export class TetheredSelectWrap extends ReactSelect {
  constructor(props) {
    super(props);
    this.renderOuter = this._renderOuter;
  }

  _renderOuter() {
    const menu = super.renderOuter.apply(this, arguments);
    if (!menu) {
      return;
    }
    const selectWidth = this.wrapper ? this.wrapper.offsetWidth : null;
    return <Tether width={selectWidth} className={this.props.tetherClassName}>{menu}</Tether>;
  }

  addValue(value) {
    const valueArray = this.getValueArray(this.props.value);
    const visibleOptions = this._visibleOptions.filter(val => !val.disabled);
    const lastValueIndex = visibleOptions.indexOf(value);
    this.setValue(valueArray.concat(value));
  }


  componentDidUpdate(prevProps, prevState) {
    this.hasScrolledToOption = true;
    super.componentDidUpdate(prevProps, prevState);
  }
}

class TetheredSelectWrapAsync extends ReactSelect.Async {
  static defaultProps = {
    ...ReactSelect.Async.defaultProps,
    children: props => <TetheredSelectWrap {...props} />,
  };
}

TetheredSelectWrap.Async = TetheredSelectWrapAsync;

export default class Select extends Input {
  static defaultProps = {
    ...Input.defaultProps,
    clearable: false,
  };

  onChange = (option) => {
    this.props.onChange({[this.props.name]: option});
  };

  onBlur = () => {
    this.props.onBlur();
  };

  renderInput() {
    let Component = this.props.loadOptions ? TetheredSelectWrap.Async : TetheredSelectWrap;
    return (
      <Component
        joinValues={true}
        clearable={this.props.clearable}
        instanceId={this.props.name}
        className={this.props.selectClassName}
        {...this.inputProps()}
      />
    );
  }
}

