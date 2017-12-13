import React from 'react';
import {imageExists} from '../global/utils';

export default class CompanyImage extends React.Component {
  static defaultProps = {
    fallback: 'https://angel.co/images/shared/nopic_startup.png',
    relaxHeight: false,
    onError: _.noop,
    onLoad: _.noop,
  };

  constructor(props) {
    super(props);

    this.state = {
      valid: false,
    };
  }

  componentWillMount() {
    this.mounted = true;
  }

  componentWillUnmount() {
    this.mounted = false;
  }

  url() {
    const { domain, size } = this.props;
    return `//logo.clearbit.com/${domain}?size=${size}`;
  }

  style() {
    const { size, relaxHeight } = this.props;
    const style = { width: size };
    if (!relaxHeight) {
      style.height = size;
    }
    return style;
  }

  checkImage() {
    if (!this.props.domain) {
      return;
    }
    const url = this.url();
    imageExists(url).then(() => {
      if (this.mounted && this.url() === url) {
        this.setState({valid: true});
        this.props.onLoad();
      }
    }).catch(() => {
      if (this.mounted && this.url() === url) {
        this.setState({valid: false});
        this.props.onError();
      }
    });
  }

  componentDidMount() {
    this.checkImage();
  }

  componentDidUpdate(prevProps, prevState) {
    if (prevProps.domain !== this.props.domain) {
      this.setState({valid: false});
      this.checkImage();
    }
  }

  render() {
    const { domain, fallback } = this.props;
    const style = this.style();
    if (!this.state.valid || !domain) {
      return fallback ? <img src={fallback} style={style} /> : null;
    }
    return <img src={this.url()} style={style} />;
  }
}