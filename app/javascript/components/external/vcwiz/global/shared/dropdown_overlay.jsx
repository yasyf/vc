import React from 'react';
import classNames from 'classnames';
import {Overlay} from 'react-overlays';

const StyleCopier = ({children, width, style, className}) => {
  let element = React.Children.only(children);
  let newClassName = classNames(element.props.className, className);
  let newStyle = {width, ...element.props.style, ...style};
  return React.cloneElement(element, {style: newStyle, className: newClassName});
};

const DropdownOverlay = elt => ({children}) => (
  <Overlay show rootClose={false} target={elt} placement="bottom">
    <StyleCopier width={elt() && elt().offsetWidth}>{children}</StyleCopier>
  </Overlay>
);

export default DropdownOverlay;