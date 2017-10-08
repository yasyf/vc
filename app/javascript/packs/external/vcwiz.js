/* eslint-disable global-require */
/* eslint no-console:0 */

import 'react-toastify/dist/ReactToastify.min.css';
import 'fixed-data-table-2/dist/fixed-data-table.css';
import 'react-select-plus/dist/react-select-plus.css';
import WebpackerReact from 'webpacker-react';

let toPath = (name) => `${name.toLowerCase()}/${name.toLowerCase()}`;
let toComponent = (name) => require(`components/external/vcwiz/${toPath(name)}`).default;

const names = ['Discover', 'Filter'];

let components = _.fromPairs(_.map(names, name => [name, toComponent(name)]));
WebpackerReact.setup(components);

if (module.hot) {
  names.forEach(name => module.hot.accept(
    `components/external/vcwiz/${toPath(name)}`,
    () => WebpackerReact.renderOnHMR(toComponent(name)))
  );
}