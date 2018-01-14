import React from 'react';
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
    return {value: props.data};
  };

  updateValue(props) {
    if (props.row) {
      const faded = props.isFaded ? props.isFaded(props.row) : false;
      this.setState({loading: false, faded, id: props.row.id, ...this.processRow(props, props.row)});
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
    const { faded } = this.state;
    return (
      <ReactPlaceholder {...this.placeholderProps()}>
        <div className="cell-padding">
          <div className={classNames('cell-wrapper', {faded})} onClick={this.onClick}>
            {this.renderValue()}
          </div>
        </div>
      </ReactPlaceholder>
    )
  }
};

export default class TextCell extends TextCellFactory(React.PureComponent) {}
export class UnpureTextCell extends TextCellFactory(React.Component) {}