import React from 'react';
import ImageTextCell from './image_text_cell';
import { CompetitorsIntroPathsPath, FirmPath } from '../constants.js.erb';
import { LocalStorage } from '../storage.js.erb';
import {ffetch, isLoggedIn} from '../utils';
import IntroPath from '../competitors/intro_path';
import inflection from 'inflection';
import FakeLink from '../shared/fake_link';

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
  componentWillMount() {
    this.mounted = true;
  }

  componentWillUnmount() {
    this.mounted = false;
  }

  processRow(props, row) {
    const { subValue, value, ...rest } = super.processRow(props, row);
    return {
      id: row.id,
      value: <FakeLink href={FirmPath.resource(row.id, inflection.dasherize(row.name.toLowerCase()))} value={value} />,
      textValue: value,
      ...rest,
    };
  };

  componentDidUpdate(prevProps, prevState) {
    if (isLoggedIn() && prevState.id !== this.state.id) {
      fetchPath(this.state.id, path => {
        if (!this.mounted) {
          return;
        }
        if (_.isEmpty(path)) {
          this.setState({subValue: null});
        } else {
          const subValue = (
            <span>
              Link: <IntroPath path={path} fullName={this.state.textValue} fullSentence={false} />
            </span>
          );
          this.setState({subValue});
        }
      });
    }
  }
}