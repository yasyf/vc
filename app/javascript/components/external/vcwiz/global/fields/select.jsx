import React from 'react';
import ReactSelect, { Async } from 'react-select-plus';
import TetherComponent from 'react-tether';
import Input from './input';

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
    return (
      <TetherComponent
        renderElementTo="body"
        attachment="top left"
        targetAttachment="top left"
        constraints={[{
          to: 'window',
          attachment: 'together',
          pin: ['top']
        }]}
        optimizations={{ gpu: false }}
      >
        <div></div>
        <div style={{position: 'static', width: selectWidth}}>{menu}</div>
      </TetherComponent>
    );
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
  onChange = (option) => {
    this.setState({value: option});
    this.props.onChange({[this.props.name]: option});
  };

  onBlur = (option) => {
    // noop
  };

  renderInput() {
    let Component = this.props.loadOptions ? TetheredSelectWrap.Async : TetheredSelectWrap;
    return (
      <Component joinValues={true} clearable={false} {...this.inputProps()} />
    );
  }
}

