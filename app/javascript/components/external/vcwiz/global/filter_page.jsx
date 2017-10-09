import React from 'react';
import Filters from '../discover/filters';

export default class FilterPage extends React.Component {
  render() {
    return (
      <div className="full-screen">
        <Filters showButton={false} showLabels={true} />
        <div className="filter-page full-screen">
          {this.props.children}
        </div>
      </div>
    )
  }
}