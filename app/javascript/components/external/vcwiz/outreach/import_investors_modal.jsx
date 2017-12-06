import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import { TargetInvestorsBulkImportPath, TargetInvestorsBulkPollPath, ImportHeadersOptions } from '../global/constants.js.erb';
import FileInput from '../global/fields/file_input';
import {ffetch, humanizeList} from '../global/utils';
import update from 'immutability-helper';
import Loader from '../global/shared/loader';
import Select from 'react-select';
import inflection from 'inflection';
import {Button, Colors} from 'react-foundation';
import { Line } from 'rc-progress';
import Table from '../global/shared/table';
import Actions from '../global/actions';

const Stage = {
  START: 'START',
  LOADING: 'LOADING',
  LOADED: 'LOADED',
  IMPORTING: 'IMPORTING',
  DONE: 'DONE',
};

export default class ImportInvestorsModal extends React.Component {
  state = {
    stage: Stage.START,
    id: null,
    errored: [],
    samples: [],
    headerRow: null,
    headers: {},
    total: 1,
    imported: 0,
  };

  componentWillUnmount() {
    window.clearInterval(this.interval);
  }

  startPolling = (id, fn) => {
    this.interval = window.setInterval(() => {
      ffetch(TargetInvestorsBulkPollPath.id(id)).then(result => {
        if (fn(result))  {
          window.clearInterval(this.interval);
        }
      });
    }, 1000);
  };

  startLoadingPolling = id => {
    this.startPolling(id, ({id, samples, headers, header_row, total}) => {
      if (!total) {
        return false;
      }
      this.setState({id, samples, headers, total, headerRow: header_row, stage: Stage.LOADED});
      return true;
    });
  };

  startImportPolling = () => {
    this.startPolling(this.state.id, ({imported, complete, duplicates, errored}) => {
      if (imported !== this.state.imported) {
        this.setState({imported});
      }
      if (complete) {
        this.setState({errored, duplicates, stage: Stage.DONE});
        return true;
      } else {
        return false;
      }
    });
  };

  onFileUpload = file => {
    this.setState({stage: Stage.LOADING});
    ffetch(TargetInvestorsBulkImportPath, 'POST', file, { form: true }).then(
      ({id, error}) => {
        if (error) {
          console.log(message);
        } else {
          this.startLoadingPolling(id);
        }
      }
    );
  };

  onUpdateHeader = (i) => (val) => {
    let headers;
    if (val === null) {
      headers = update(this.state.headers, {$unset: [i]});
    } else {
      headers = update(this.state.headers, {[i]: {$set: val.value}});
    }
    this.setState({headers});
  };

  onClick = () => {
    const { id, headers } = this.state;
    this.setState({stage: Stage.IMPORTING});
    ffetch(TargetInvestorsBulkImportPath, 'POST', {id, headers}).then(this.startImportPolling);
  };

  onClose = () => {
    Actions.trigger('refreshFounder');
    this.props.onClose();
  };

  options(i) {
    let used = Object.values(this.state.headers);
    let options = _.reject(ImportHeadersOptions, o => used.includes(o.value));
    if (used.includes('first_name') || used.includes('last_name')) {
      _.remove(options, {value: 'name'});
    }
    if (used.includes('name')) {
      _.remove(options, {value: 'first_name'});
      _.remove(options, {value: 'last_name'});
    }
    if (i !== -1 && this.state.headers[i]) {
      options.push(_.find(ImportHeadersOptions, {value: this.state.headers[i]}));
    }
    return options;
  }

  placeholder(i, disabled) {
    const { headerRow } = this.state;
    if (headerRow && headerRow[i]) {
      return <em>{headerRow[i]}</em>;
    } else {
      return disabled ? 'All Assigned!' : 'Select Header...';
    }
  }

  renderRemaining() {
    const options = this.options(-1);
    if (!options.length) {
      return <span>You've assigned all the columns!</span>;
    }
    return (
      <span>
        You can still assign the {humanizeList(options.map(({label}) => <b>{label}</b>))} {inflection.inflect('columns', options.length)}.
      </span>
    );
  }

  renderButton() {
    if (this.state.stage === Stage.LOADED) {
      const { total } = this.state;
      return (
        <div className="button-wrapper" key="button">
          <p>
            Below is a preview of your import. There's a total of {total} rows.
          </p>
          <p>
            We've tried to figure out which of your columns match up with ours, but we need a little help!
            Please use the dropdowns above each column to show us your setup.
            We probably won't support all your columns, and you might not have all of ours.
          </p>
          <p>
            {' '}
            {this.renderRemaining()}
            {' '}
          </p>
          <Button color={Colors.SUCCESS} onClick={this.onClick}>
            Finish Import
          </Button>
        </div>
      );
    } else if (this.state.stage === Stage.DONE) {
      return (
        <div className="button-wrapper" key="button">
          <Button onClick={this.onClose}>
            Close
          </Button>
        </div>
      );
    } else {
      return null;
    }
  }

  renderTop() {
    return _.compact([
      <h3 className="title" key="heading">Import Investor Spreadsheet</h3>,
      this.renderButton(),
    ]);
  }

  renderSamples() {
    const selects = _.range(this.state.samples[0].length).map(i => {
      const options = this.options(i);
      const disabled = options.length === 0;
      return (
        <Select
          clearable={!!this.state.headers[i]}
          value={this.state.headers[i]}
          options={options}
          onChange={this.onUpdateHeader(i)}
          disabled={disabled}
          placeholder={this.placeholder(i, disabled)}
        />
      );
    });
    return <Table headers={selects} rows={this.state.samples} headerClass="import-header" />;
  }

  renderStart() {
    return (
      <div className="main">
        <p>
          Already have a spreadsheet of investors? You can use this form to import them!
          Please export them in CSV format before uploading.
        </p>
        <FileInput
          type="file"
          name="file"
          placeholder="Import CSV"
          accept=".csv"
          onChange={this.onFileUpload}
        />
      </div>
    );
  }

  renderLoader() {
    return (
      <div className="loader-wrapper">
        <div className="loader">
          <h3>Loading Preview</h3>
          <Loader spinner="BeatLoader" size={50} />
        </div>
      </div>
    );
  }

  renderProgress() {
    const { imported, total } = this.state;
    const percent = Math.round((imported / total) * 100);
    return (
      <div className="progress-wrapper">
        <h2 className="percent">{percent}%</h2>
        <Line percent={percent} strokeWidth={1} strokeColor="#2ADBC4" />
      </div>
    );
  }

  renderDuplicates() {
    const { duplicates, headerRow } = this.state;
    if (!duplicates.length) {
      return null;
    }
    return (
      <div>
        <p>There were {duplicates.length} duplicates (shown below), which were not imported.</p>
        <Table headers={headerRow} rows={duplicates} headerClass="error-header" />
      </div>
    );
  }

  renderErrors() {
    const { errored } = this.state;
    if (!errored.length) {
      return 'There were no errors.';
    } else {
      return (
        <span>
          There {inflection.inflect('were', errored.length, 'was')} {errored.length} {inflection.inflect('errors', errored.length)}.
          {' '}
          {inflection.inflect('Lines', errored.length)} {humanizeList(errored)} {inflection.inflect('are', errored.length, 'is')} invalid!
        </span>
      );
    }
  }

  renderDone() {
    const { imported } = this.state;
    return (
      <div className="main">
        We successfully imported <b>{imported}</b> investors. {this.renderErrors()}
        {this.renderDuplicates()}
      </div>
    )
  }

  renderBottom() {
    switch (this.state.stage) {
      case Stage.START:
        return this.renderStart();
      case Stage.LOADING:
        return  this.renderLoader();
      case Stage.LOADED:
        return this.renderSamples();
      case Stage.IMPORTING:
        return this.renderProgress();
      case Stage.DONE:
        return this.renderDone();
      default:
        return null;
    }
  }

  render() {
    return (
      <OverlayModal
        name="import_investors"
        top={this.renderTop()}
        bottom={this.renderBottom()}
        {...this.props}
      />
    );
  }
}