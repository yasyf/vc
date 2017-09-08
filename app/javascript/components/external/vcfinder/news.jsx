import React from 'react';

export default class News extends React.Component {
  render() {
    let {title, description, url} = this.props.news;
    return (
      <div className="pull-right">
        <h6>
          <a href={url} target="_blank">{title}</a>
        </h6>
        <p><small>{description}</small></p>
      </div>
    );
  }
}