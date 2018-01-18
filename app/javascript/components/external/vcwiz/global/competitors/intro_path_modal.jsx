import React from 'react';
import OverlayModal from '../shared/overlay_modal';
import {ffetch} from '../utils';
import IntroPath from './intro_path';
import StandardLoader from '../shared/standard_loader';
import inflection from 'inflection';
import {CompetitorsPath, InvestorsPath, IntroPathTypes} from '../constants.js.erb';
import {Row, Column} from 'react-foundation';
import { canUseDOM } from 'exenv';
import Store from '../store';
import classNames from 'classnames';
import hasModalErrorBoundary from '../shared/has_modal_error_boundary';

// eslint-disable-next-line global-require
const Graph = canUseDOM && require('react-graph-vis').default;

@hasModalErrorBoundary
export default class IntroPathModal extends React.Component {
  state = {
    loading: true,
    paths: [],
    counts: {},
  };

  static graphFromPaths(paths) {
    const founder = Store.get('founder', {});
    const nodes = _.uniqBy(_.flatMap(paths, ({through}) => through.map((node, i) => ({
      id: node.id,
      label: node.first_name,
      image: node.photo,
      shape: node.photo ? 'circularImage' : 'circle',
      level: i + 2,
    }))), 'id').concat([{id: 'me', label: founder.first_name, image: founder.photo, shape: 'circularImage', level: 1}]);
    const edges = _.uniqWith(_.flatMap(paths, ({through}) => _.compact(_.map(through, (node, i) => ({
      from: i === 0 ? 'me' : through[i - 1].id,
      to: node.id,
    })))), _.isEqual);
    return { nodes, edges };
  }

  componentDidMount() {
    const { path, id } = this.props;
    ffetch(path.resource(id, 'intro_paths')).then(({paths}) => {
      const startCount = _.uniq(_.map(paths, ({through}) => _.first(through))).length;
      const endCount = _.uniq(_.map(paths, ({through}) => _.last(through))).length;
      const graph = IntroPathModal.graphFromPaths(paths);
      this.setState({paths, startCount, endCount, graph, loading: false});
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
        <Row className="metrics">
          <Column large={4}>{this.renderMetric(count, 'Paths')}</Column>
          <Column large={4}>{this.renderMetric(startCount, 'Connections')}</Column>
          <Column large={4}>{this.renderMetric(endCount, 'Investors')}</Column>
        </Row>
      );
    } else {
      return (
        <Row className="metrics">
          <Column large={6}>{this.renderMetric(count, 'Paths')}</Column>
          <Column large={6}>{this.renderMetric(startCount, 'Connections')}</Column>
        </Row>
      );
    }
  }

  renderGraph() {
    const { count } = this.props;
    const { graph } = this.state;
    if (!canUseDOM || count <= 1) {
      return null;
    }
    return (
      <div className="graph">
        <Graph
          identifier="graph"
          graph={graph}
          getNetwork={network => { this.network = network }}
          options={{
            nodes: {
              color: 'rgba(48, 116, 238, 0.3)',
              font: {
                size: 16,
                face: 'Circular Std',
              },
            },
            edges: {
              width: 2,
              arrowStrikethrough: false,
              smooth: true,
            },
            interaction: {
              dragNodes: false,
            },
            layout: {
              hierarchical: {
                direction: 'DU',
              },
            },
          }}
          events={{
            stabilized: () => this.network.focus('me'),
          }}
        />
      </div>
    );
  }

  renderModal() {
    const { count } = this.props;
    const { loading, paths } = this.state;
    if (loading) {
      return <StandardLoader />;
    }
    return (
      <div className="intro_paths">
        {this.renderInfo()}
        <div className={classNames('paths', {'no-graph': count <= 1})}>
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