import React from 'react';
import Actions from '../actions';

const hasModalErrorBoundary = Component => class extends React.Component {
  componentDidCatch(error, info) {
    Raven.captureException(error, {extra: info});
    Actions.trigger('flash', {type: 'alert', message: 'Sorry! An error occurred. Our team is on it.'});
    this.props.onClose && this.props.onClose();
    window.scrollTo(0, 0); // ugh so hacky
  }

  render() {
    return <Component {...this.props} />;
  }
};

export default hasModalErrorBoundary;