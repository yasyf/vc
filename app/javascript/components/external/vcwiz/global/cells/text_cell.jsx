import React from 'react';
import { PulseLoader as Loader } from 'react-spinners';
import {Cell} from 'fixed-data-table-2';
import {Textfit} from 'react-textfit';

let TextCellFactory = (superclass) => class extends superclass {
  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      value: null,
    };
  }

  processRow(props, row) {
    return {value: row[props.columnKey]};
  };

  updateValue(props) {
    let row = props.data.getSync(props.rowIndex);
    if (row) {
      this.setState({loading: false, ...this.processRow(props, row)});
    } else {
      this.setState({loading: true});
    }
  }

  componentDidMount() {
    this.updateValue(this.props);
  }

  componentWillReceiveProps(nextProps) {
    this.updateValue(nextProps);
  }

  renderValue() {
    if (!this.state.value) {
      return null;
    }
    return <Textfit mode="single" min={12} max={18}>{this.state.value}</Textfit>;
  }

  render() {
    const { height, width, columnKey, rowIndex } = this.props;
    return (
      <Cell {...{height, width, columnKey, rowIndex}}>
        {this.state.loading ? <Loader color="#2ADBC4" /> : this.renderValue()}
      </Cell>
    )
  }
};

export default class TextCell extends TextCellFactory(React.PureComponent) {}
export class UnpureTextCell extends TextCellFactory(React.Component) {}