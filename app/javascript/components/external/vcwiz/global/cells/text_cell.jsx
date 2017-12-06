import React from 'react';
import {Cell} from 'fixed-data-table-2';
import {Textfit} from 'react-textfit';
import ReactPlaceholder from 'react-placeholder';
import classNames from 'classnames';

let TextCellFactory = (superclass) => class extends superclass {
  static defaultProps = {
    onClick: _.noop,
    min: 12,
    max: 18,
  };

  constructor(props) {
    super(props);

    this.state = {
      faded: false,
      loading: true,
      value: null,
    };
  }

  onChange = change => {
    let key = this.props.columnKey;
    let value = change[key].value;
    this.setState({value});
    this.props.onChange(this.props.rowIndex, _.set({}, key, value));
  };

  processRow(props, row) {
    return {value: _.get(row, props.columnKey)};
  };

  updateValue(props) {
    let row = props.data.getSync(props.rowIndex);
    if (row) {
      const faded = props.isFaded ? props.isFaded(row) : false;
      this.setState({loading: false, faded, ...this.processRow(props, row)});
    } else {
      this.setState({loading: true, faded: false});
    }
  }

  componentDidMount() {
    this.updateValue(this.props);
  }

  componentWillReceiveProps(nextProps) {
    this.updateValue(nextProps);
  }

  onClick = e => {
    this.props.onClick(e, this.props.rowIndex);
  };

  renderValue() {
    if (!this.state.value) {
      return null;
    }
    return (
      <Textfit mode="single" min={this.props.min} max={this.props.max}>
        <span className="textfit-cell">
          {this.state.value}
        </span>
      </Textfit>
    );
  }

  placeholderProps() {
    return {
      ready: !this.state.loading,
      type: 'text',
      rows: 3,
      style: {maxWidth: '90%'},
      showLoadingAnimation: true,
    };
  }

  render() {
    const { height, width, columnKey, rowIndex } = this.props;
    const { faded } = this.state;
    return (
      <ReactPlaceholder {...this.placeholderProps()}>
        <Cell {...{height, width, columnKey, rowIndex}}>
          <div className={classNames('cell-wrapper', {faded})} onClick={this.onClick}>
            {this.renderValue()}
          </div>
        </Cell>
      </ReactPlaceholder>
    )
  }
};

export default class TextCell extends TextCellFactory(React.PureComponent) {}
export class UnpureTextCell extends TextCellFactory(React.Component) {}