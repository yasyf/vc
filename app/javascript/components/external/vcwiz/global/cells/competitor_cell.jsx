import React from 'react';
import ImageTextCell from './image_text_cell';
import { FirmPath } from '../constants.js.erb';
import { isLoggedIn } from '../utils';
import IntroPath from '../competitors/intro_path';
import inflection from 'inflection';
import FakeLink from '../shared/fake_link';
import {Textfit} from 'react-textfit';
import fetchCompetitorPath from '../fetch_competitor_path';

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

  renderTextfit() {
    return (
      <Textfit key="value" mode="multi" min={this.props.min} max={this.props.max}>
        <div className="textfit-cell" style={{height: (this.props.size * 2) - 15}}>
          <div>
            {this.state.value}
            <div className="subheading">
              {this.state.subValue}
            </div>
          </div>
        </div>
      </Textfit>
    );
  }

  componentDidUpdate(prevProps, prevState) {
    if (isLoggedIn() && prevState.id !== this.state.id) {
      fetchCompetitorPath(this.state.id, path => {
        if (!this.mounted) {
          return;
        }
        if (_.isEmpty(path)) {
          this.setState({subValue: null, badge: null});
        } else {
          const subValue = <IntroPath path={path} short={true} />;
          this.setState({subValue, badge: path.through.length});
        }
      });
    }
  }
}