/* eslint no-console:0 */

import VCWiz from 'components/external/vcwiz/vcwiz';
import WebpackerReact from 'webpacker-react';

import 'react-toastify/dist/ReactToastify.min.css';

WebpackerReact.setup({VCWiz});

if (module.hot) {
  Object.entries({
    VCWiz: 'components/external/vcwiz/vcwiz',
  }).forEach(([comp, path]) => module.hot.accept(path, () => WebpackerReact.renderOnHMR(comp)));
}