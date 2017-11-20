import React from 'react';

export default class Loader extends React.Component {
  static defaultProps = {
    size: 200,
    color: "#3074EE",
  };

  constructor(props) {
    super(props);

    this.state = {
      hasMounted: false,
    };
  }

  componentDidMount() {
    this.setState({hasMounted: true});
  }

  render() {
    if (this.state.hasMounted) {
      const RingLoader = require('react-spinners').RingLoader;
      return <RingLoader {...this.props} />;
    } else {
      return null;
    }
  }
}