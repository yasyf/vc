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
    Object.entries(intro_paths).forEach(([id, path]) => {
      LocalStorage.setExpr(`IntroPath::${id}`, path || {}, 60*60*24);
      if (!_.isEmpty(path)) {
        pending[id](path);
      }
    });
  });
}, 500);
const fetchPath = (id, cb) => {
  const cached = LocalStorage.getExpr(`IntroPath::${id}`);
  if (cached) {
    if (!_.isEmpty(cached)) {
      cb(cached);
    }
  } else {
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
        const subValue = (
          <span>
            Connected <IntroPath path={path} fullName={this.state.value} fullSentence={false} />
          </span>
        );
        this.setState({subValue});
      });
    }
  }
}