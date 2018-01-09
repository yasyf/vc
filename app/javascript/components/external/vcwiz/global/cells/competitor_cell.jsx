import React from 'react';
import ImageTextCell from './image_text_cell';
import {FirmPath, IntroPathTypes} from '../constants.js.erb';
import { isLoggedIn } from '../utils';
import inflection from 'inflection';
import FakeLink from '../shared/fake_link';
import fetchCompetitorPath from '../fetch_competitor_path';
import IntroPathCount from '../competitors/intro_path_count';

export default class CompetitorCell extends ImageTextCell {
  componentWillMount() {
    this.mounted = true;
  }

  componentWillUnmount() {
    this.mounted = false;
  }

  processRow(props, row) {
    const { subValue, value, badge, ...rest } = super.processRow(props, row);
    return {
      id: row.id,
      value: <FakeLink href={FirmPath.resource(row.id, inflection.dasherize(row.name.toLowerCase()))} value={value} />,
      textValue: value,
      ...rest,
    };
  };

  componentDidUpdate(prevProps, prevState) {
    if (isLoggedIn() && prevState.id !== this.state.id) {
      fetchCompetitorPath(this.state.id, path => {
        if (!this.mounted) {
          return;
        }
        if (_.isEmpty(path)) {
          this.setState({subValue: null, badge: null});
        } else {
          const subValue =
            <IntroPathCount {...path} short={true} path={IntroPathTypes.COMPETITOR} id={this.state.id} />;
          this.setState({subValue, badge: path.count});
        }
      });
    }
  }
}