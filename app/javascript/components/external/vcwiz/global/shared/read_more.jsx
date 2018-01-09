import React  from 'react';
import Truncate from 'react-truncate';

export default class ReadMore extends React.Component {
  static defaultProps = {
    onTruncate: _.noop,
    block: false,
    initiallyExpanded: false,
    lines: 2,
    more: 'more',
    less: 'less',
  };

  constructor(props) {
    super(props);

    this.state = {
      expanded: props.initiallyExpanded,
    };
  }

  handleTruncate = (truncated) => {
    if (this.state.truncated !== truncated) {
      this.setState({truncated});
    }
    this.props.onTruncate(truncated);
  };

  toggleLines = (event) => {
    event.preventDefault();
    this.setState({expanded: !this.state.expanded});
  };

  renderLess() {
    const {less} = this.props;
    const {expanded, truncated} = this.state;
    if (!truncated && expanded) {
      return <span key="less"> <a href='#' onClick={this.toggleLines}>{less}</a></span>;
    } else {
      return null;
    }
  }

  renderReadMore() {
    const {children, more, lines, length} = this.props;
    const {expanded} = this.state;

    if (length && length < 50) {
      return children;
    }

    return _.compact([
      <Truncate
        lines={!expanded && lines}
        ellipsis={<span>... <a href='#' onClick={this.toggleLines}>{more}</a></span>}
        onTruncate={this.handleTruncate}
        key="truncate"
      >
        {children}
      </Truncate>,
      this.renderLess()
    ]);
  }

  render() {
    if (this.props.block) {
      return <div>{this.renderReadMore()}</div>;
    } else {
      return <span>{this.renderReadMore()}</span>;
    }
  }
}