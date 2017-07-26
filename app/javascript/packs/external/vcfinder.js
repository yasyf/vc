/* eslint no-console:0 */

import VCFinder from 'components/external/vcfinder/vcfinder';
import VCFinderAdmin from 'components/external/vcfinder/vcfinder_admin';
import VCFinderLogin from 'components/external/vcfinder/vcfinder_login';
import WebpackerReact from 'webpacker-react';

import 'react-toastify/dist/ReactToastify.min.css';

WebpackerReact.setup({VCFinder, VCFinderAdmin, VCFinderLogin});

if (module.hot) {
  Object.entries({
    VCFinder: 'components/external/vcfinder/vcfinder',
    VCFinderAdmin: 'components/external/vcfinder/vcfinder_admin',
    VCFinderLogin: 'components/external/vcfinder/vcfinder_login',
  }).forEach(([comp, path]) => module.hot.accept(path, () => WebpackerReact.renderOnHMR(comp)));
}