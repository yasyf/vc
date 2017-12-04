import React from 'react';

export default class Loader extends React.Component {
  static defaultProps = {
    size: 200,
    color: "#3074EE",
    spinner: 'RingLoader',
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

  getSpinner() {
    return require('react-spinners')[this.props.spinner];
  }

  render() {
    if (this.state.hasMounted) {
      const Spinner = this.getSpinner();
      return <Spinner {...this.props} />;
    } else {
      return null;
    }
  }
}