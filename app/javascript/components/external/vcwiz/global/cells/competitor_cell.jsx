import React from 'react';
import ImageTextCell from './image_text_cell';
import { CompetitorsIntroPathsPath } from '../constants.js.erb';
import { LocalStorage } from '../storage.js.erb';
import {ffetch, isLoggedIn} from '../utils';
import IntroPath from '../competitors/intro_path';

let pendingPaths = {};
const fetchPaths = _.debounce(() => {
  const pending = pendingPaths;
  pendingPaths = {};

  ffetch(`${CompetitorsIntroPathsPath}?ids=${Object.keys(pending).join(',')}`).then(({intro_paths}) => {
    Object.entries(pending).forEach(([id, cb]) => {
      const path = intro_paths[id] || {};
      LocalStorage.setExpr(`IntroPath::${id}`, path, 60*60*24);
      cb(path);
    });
  });
}, 500);
const fetchPath = (id, cb) => {
  const cached = LocalStorage.getExpr(`IntroPath::${id}`);
  if (cached) {
    cb(cached);
  } else {
    cb(null);
    pendingPaths[id] = cb;
    fetchPaths();
  }
};

export default class CompetitorCell extends ImageTextCell {
  processRow(props, row) {
    const { subValue, ...rest } = super.processRow(props, row);
    return {
      id: row.id,
      ...rest,
    };
  };

  componentDidUpdate(prevProps, prevState) {
    if (isLoggedIn() && prevState.id !== this.state.id) {
      fetchPath(this.state.id, path => {
        if (_.isEmpty(path)) {
          this.setState({subValue: null});
        } else {
          const subValue = (
            <span>
              Connected <IntroPath path={path} fullName={this.state.value} fullSentence={false} />
            </span>
          );
          this.setState({subValue});
        }
      });
    }
  }
}