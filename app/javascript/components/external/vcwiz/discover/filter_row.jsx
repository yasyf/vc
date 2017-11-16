import React from 'react';
import {buildQuery, ffetch, flattenFilters} from '../global/utils';
import {Button, Column, Colors, Row} from 'react-foundation';
import inflection from 'inflection';
import Filters from './filters';

export default class FilterRow extends React.Component {
  static defaultProps = {
    onChange: _.noop,
    onButtonClick: _.noop,
  };

  constructor(props) {
    super(props);

    this.state = {
      numInvestors: this.props.initialCount,
      filters: flattenFilters(this.props.initialFilters || {}),
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    return (
      nextState.numInvestors !== this.state.numInvestors
      || !_.isEqual(nextState.filters, this.state.filters)
    )
  }

  componentDidUpdate(prevProps, prevState) {
    if (buildQuery(this.props.countSource.query) !== buildQuery(prevProps.countSource.query)) {
      this.fetchNumInvestors(this.state.filters)
    }
  }

  fetchNumInvestors(filters) {
    const {path, query} = this.props.countSource;
    let built = buildQuery({...query, ...filters});
    if (built) {
      ffetch(`${path}?${built}`).then(({count, suggestions}) => {
        this.setState({numInvestors: count, suggestions});
        this.props.onChange(filters, count, suggestions);
      });
    } else {
      ffetch(path).then(({count, suggestions}) => {
        this.setState({numInvestors: null, suggestions});
        this.props.onChange({}, count, suggestions);
      });
    }
  }

  onChange = filters => {
    if (_.isEqual(filters, this.state.filters)) {
      return;
    }
    this.setState({filters});
    this.fetchNumInvestors(filters);
  };

  numInvestors() {
    if (!this.state.numInvestors) {
      return null;
    }
    return this.state.numInvestors;
  }

  meta() {
    if (!this.state.numInvestors) {
      return null;
    }
    return `Filter Results (${this.state.numInvestors})`;
  }

  renderButton() {
    return (
      <div className="boxed">
        <Button color={Colors.SUCCESS} onClick={this.props.onButtonClick}>
          Find {this.numInvestors()} {inflection.inflect('Investors', this.state.numInvestors)}
        </Button>
      </div>
    );
  }

  render() {
    const { initialCount, countSource, onChange, onButtonClick, ...rest } = this.props;
    const filters = <Filters onChange={this.onChange} meta={this.meta()} {...rest} />;
    return (
      <div className="filters">
        {filters}
      </div>
    );
  }
}