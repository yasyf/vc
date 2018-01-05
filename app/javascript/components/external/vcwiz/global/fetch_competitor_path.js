import {CompetitorsIntroPathsPath, StoragePrefix} from './constants.js.erb';
import {ffetch} from './utils';
import {LocalStorage} from './storage.js.erb';

let pendingPaths = {};

const fetchPaths = _.debounce(() => {
  const pending = pendingPaths;
  pendingPaths = {};

  ffetch(`${CompetitorsIntroPathsPath}?ids=${Object.keys(pending).join(',')}`).then(({intro_paths}) => {
    Object.entries(pending).forEach(([id, cb]) => {
      const path = intro_paths[id] || {};
      LocalStorage.setExpr(`${StoragePrefix}::IntroPath::${id}`, path, 60*60*24);
      cb(path);
    });
  });
}, 500);

const fetchCompetitorPath = (id, cb) => {
  const cached = LocalStorage.getExpr(`${StoragePrefix}::IntroPath::${id}`);
  if (cached) {
    cb(cached);
  } else {
    cb(null);
    pendingPaths[id] = cb;
    fetchPaths();
  }
};

export default fetchCompetitorPath;