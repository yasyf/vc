import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import {ffetch} from '../utils';
import IntroPath from './intro_path';
import StandardLoader from '../shared/standard_loader';
import inflection from 'inflection';
import {CompetitorsPath, InvestorsPath, IntroPathTypes} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';

export default class IntroPathModal extends React.Component {
  state = {
    loading: true,
    paths: [],
    counts: {},
  };

  componentDidMount() {
    const { path, id } = this.props;
    ffetch(path.resource(id, 'intro_paths')).then(({paths}) => {
      const startCount = _.uniq(_.map(paths, ({through}) => _.first(through))).length;
      const endCount = _.uniq(_.map(paths, ({through}) => _.last(through))).length;
      this.setState({paths, startCount, endCount, loading: false});
    });
  }

  renderPath = (path, i) => <IntroPath key={i} path={path} />;

  renderMetric = (metric, caption) => (
    <div className="metric-wrapper">
      <div className="metric">{metric}</div>
      <div className="caption">{inflection.inflect(caption, metric)}</div>
    </div>
  );

  renderInfo() {
    const { count, path } = this.props;
    const { startCount, endCount } = this.state;

    if (path === IntroPathTypes.COMPETITOR) {
      return (
        <Row>
          <Column large={4}>{this.renderMetric(count, 'Paths')}</Column>
          <Column large={4}>{this.renderMetric(startCount, 'Connections')}</Column>
          <Column large={4}>{this.renderMetric(endCount, 'Investors')}</Column>
        </Row>
      );
    } else {
      return (
        <Row>
          <Column large={6}>{this.renderMetric(count, 'Paths')}</Column>
          <Column large={6}>{this.renderMetric(startCount, 'Connections')}</Column>
        </Row>
      );
    }
  }

  renderGraph() {
    return null;
  }

  renderModal() {
    const { loading, paths } = this.state;
    if (loading) {
      return <StandardLoader />;
    }
    return (
      <div className="intro_paths">
        {this.renderInfo()}
        <div className="paths">
          {paths.map(this.renderPath)}
        </div>
        {this.renderGraph()}
      </div>
    )
  }

  render() {
    return (
      <OverlayModal
        name="intro_path"
        modal={this.renderModal()}
        {...this.props}
      />
    );
  }
}