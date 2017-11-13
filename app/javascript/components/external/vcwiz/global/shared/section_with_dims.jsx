import React from 'react';
import {withDims} from '../utils';
import Store from '../store';

class Section extends React.Component {
  render() {
    const {page, children, containerWidth, containerHeight, dimensionsKey} = this.props;
    let element = React.Children.only(children);
    const dimensions = {width: containerWidth, height: containerHeight};
    const style = {...element.props.style, ...dimensions};
    if (dimensionsKey) {
      Store.set(dimensionsKey, dimensions);
    }
    return React.cloneElement(element, {style});
  }
}
const SectionWithDims = withDims(Section);
export default SectionWithDims;