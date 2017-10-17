import React from 'react';

export default class IconLine extends React.Component {
  render() {
    const { icon, line, link, text } = this.props;
    if (!line && (!text || !link)) {
      return null;
    }
    let inner = text || line;
    let href = text ? link : `${link}/${line}`;
    let body = link ? <a href={href} target="_blank">{inner}</a> : inner;
    return <p className="icon"><i className={`line-icon fi-${icon}`}/>{body}</p>;
  }
}