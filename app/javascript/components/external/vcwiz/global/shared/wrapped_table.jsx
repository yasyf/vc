import React from 'react';
import LazyArray from '../lazy_array';
import Store from '../store';

class FixedWrappedTable extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      dimensions: Store.get('dimensions', {
        width: 0,
        height: 0,
      }),
    };
  }

  componentWillMount() {
    this.subscription = Store.subscribe('dimensions', dimensions => {
      setTimeout(() => this.setState({dimensions}), 0);
    });
  }

  componentWillUnmount() {
    Store.unsubscribe(this.subscription);
  }

  shouldComponentUpdate(nextProps, nextState) {
    return (
      nextProps.resultsId !== this.props.resultsId ||
      nextState.dimensions !== this.state.dimensions
    );
  }

  render() {
    const { table, ...rest } = this.props;
    const { dimensions } = this.state;
    const BackingTable = table;
    return (
      <div className="full-screen">
        <BackingTable dimensions={dimensions} {...rest} />
      </div>
    );
  }
}

export default class WrappedTable extends React.Component {
  static nextState(props) {
    return {
      array: new LazyArray(props.source, props.items),
    };
  }

  constructor(props) {
    super(props);

    this.state = {
      currentModal: null,
      ...WrappedTable.nextState(props),
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.resultsId !== this.props.resultsId) {
      this.setState(WrappedTable.nextState(nextProps));
    }
  }

  onRowUpdate = (i, update) => {
    this.setState({array: this.state.array.dup().set(i, update)});
  };

  onModalClose = i => () => {
    this.setState({currentModal: null});
  };

  onModalResult = i => (result, keepOpen) => {
    if (!keepOpen) {
      this.onModalClose(i)();
    }
    if (result) {
      this.onRowUpdate(i, result);
    }
  };

  onCellClick = (i, key) => {
    this.setState({currentModal: [i, key]});
  };

  getModal(key) {
    const { modal } = this.props;
    if (!modal) {
      return null;
    }
    if (_.isObject(modal) && !_.isFunction(modal)) {
      return modal[key];
    } else if (modal.prototype.isReactComponent) {
      return modal;
    } else if (_.isFunction(modal)) {
      return modal(key);
    } else {
      return null;
    }
  }

  renderCurrentModal() {
    const { currentModal, array } = this.state;
    if (currentModal === null) {
      return null;
    }
    const [i, key] = currentModal;
    const Modal = this.getModal(key);
    if (!Modal) {
      return null;
    }
    return (
      <Modal
        key="modal"
        onClose={this.onModalClose(i)}
        onResult={this.onModalResult(i)}
        rowKey={key}
        item={array.getSync(i)}
      />
    );
  }

  render() {
    const { modal, source, items, ...rest } = this.props;
    const { array } = this.state;
    return [
      this.renderCurrentModal(),
      <FixedWrappedTable
        key="table"
        array={array}
        onCellClick={this.onCellClick}
        onRowUpdate={this.onRowUpdate}
        {...rest}
      />,
    ];
  }
}