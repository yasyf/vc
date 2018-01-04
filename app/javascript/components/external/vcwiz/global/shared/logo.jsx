import React from 'react';
import {imageExists} from '../utils';
import {LogoImagePath} from '../constants.js.erb';

export default class Logo extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      loaded: false,
    };
  }

  componentWillMount() {
    this.mounted = true;
  }

  componentWillUnmount() {
    this.mounted = false;
  }

  checkImage() {
    imageExists(LogoImagePath).then(() => {
      if (this.mounted)
        this.setState({loaded: true});
    }).catch(_.noop);
  }

  componentDidMount() {
    this.checkImage();
  }

  render() {
    if (this.state.loaded) {
      return <img className="logo" src={LogoImagePath} />;
    } else {
      return <h3><b>VCWiz</b></h3>;
    }
  }
}