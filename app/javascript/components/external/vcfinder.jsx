// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react'

class VCFinder extends React.Component {
  render() {
    return (
      <div className="top-bar">
        <div class="top-bar-left">
          <ul class="menu">
            <li><input type="search" placeholder="Search"></li>
          </ul>
        </div>
      </div>
    );
  }
}

export default VCFinder
