import React from 'react';
import classNames from 'classnames';
import {UnpureTextCell} from './text_cell';
import Select from '../fields/select';
import {TargetInvestorStagesOptions} from '../constants.js.erb'
import {Overlay} from 'react-overlays';

const StyleCopier = ({children, style, className}) => {
  let element = React.Children.only(children);
  let newClassName = classNames(element.props.className, className);
  let newStyle = {...element.props.style, ...style};
  return React.cloneElement(element, {style: newStyle, className: newClassName});
};

const DropdownOverlay = elt => ({children}) => (
  <Overlay show rootClose={false} target={elt} placement="bottom">
    <StyleCopier className="track">{children}</StyleCopier>
  </Overlay>
);

const nullRenderer = () => null;

export default class TrackCell extends UnpureTextCell {
  onChange = change => {
    console.log(change);
    this.setState({value: change.track.value});
  };

  renderValue() {
    return (
      <Select
        name="track"
        value={this.state.value}
        placeholder="Add"
        multi={false}
        searchable={false}
        onChange={this.onChange}
        options={TargetInvestorStagesOptions}
        arrowRenderer={this.state.value ? undefined : nullRenderer}
        dropdownComponent={DropdownOverlay(this.select)}
        ref={select => { this.select = select }}
      />
    )
  }
}