import React from 'react';
import {Cell} from 'fixed-data-table-2';
import {Textfit} from 'react-textfit';
import ReactPlaceholder from 'react-placeholder';

let TextCellFactory = (superclass) => class extends superclass {
  static defaultProps = {
    onClick: _.noop,
  };

  constructor(props) {
    super(props);

    this.state = {
      loading: true,
      value: null,
    };
  }

  processRow(props, row) {
    return {value: _.get(row, props.columnKey)};
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

  onClick = e => {
    this.props.onClick(e, this.props.rowIndex);
  };

  renderValue() {
    if (!this.state.value) {
      return null;
    }
    return (
      <Textfit mode="single" min={12} max={20}>
        <div className="textfit-cell">
          {this.state.value}
        </div>
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
    return (
      <ReactPlaceholder {...this.placeholderProps()}>
        <Cell {...{height, width, columnKey, rowIndex}}>
          <div className="cell-wrapper" onClick={this.onClick}>
            {this.renderValue()}
          </div>
        </Cell>
      </ReactPlaceholder>
    )
  }
};

export default class TextCell extends TextCellFactory(React.PureComponent) {}
export class UnpureTextCell extends TextCellFactory(React.Component) {}