/* eslint no-console:0 */

import VCFinder from 'components/external/vcfinder/vcfinder'
import VCFinderAdmin from 'components/external/vcfinder/vcfinder_admin'
import WebpackerReact from 'webpacker-react'

WebpackerReact.setup({VCFinder, VCFinderAdmin});

if (module.hot) {
  Object.entries({
    VCFinder: 'components/external/vcfinder/vcfinder',
    VCFinderAdmin: 'components/external/vcfinder/vcfinder_admin',
  }).forEach(([comp, path]) => module.hot.accept(path, () => WebpackerReact.renderOnHMR(comp)));
}