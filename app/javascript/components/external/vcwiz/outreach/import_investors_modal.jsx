import React from 'react';
import OverlayModal from '../global/shared/overlay_modal';
import { TargetInvestorsBulkImportPath, TargetInvestorsBulkPollPath, ImportHeadersOptions } from '../global/constants.js.erb';
import FileInput from '../global/fields/file_input';
import {ffetch} from '../global/utils';
import update from 'immutability-helper';
import Loader from '../global/shared/loader';
import Select from 'react-select';
import {Button, Colors} from 'react-foundation';
import { Line } from 'rc-progress';
import Table from '../global/shared/table';

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
    this.startPolling(this.state.id, ({imported, complete, errored}) => {
      if (imported !== this.state.imported) {
        this.setState({imported});
      }
      if (complete) {
        this.setState({errored, stage: Stage.DONE});
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

  options(i) {
    let used = Object.values(this.state.headers);
    let options = _.reject(ImportHeadersOptions, o => used.includes(o.value));
    if (this.state.headers[i]) {
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

  renderButton() {
    if (this.state.stage === Stage.LOADED) {
      return (
        <div className="button-wrapper" key="button">
          <Button color={Colors.SUCCESS} onClick={this.onClick}>
            Finish Import
          </Button>
        </div>
      );
    } else if (this.state.stage === Stage.DONE) {
      return (
        <div className="button-wrapper" key="button">
          <Button onClick={this.props.onClose}>
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
        <div className="loader" style={{width: 200, height: 200}}>
          <Loader size={200} />
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

  renderErrors() {
    const { errored, headerRow } = this.state;
    if (!errored) {
      return null;
    }
    return <Table headers={headerRow} rows={errored} headerClass="error-header" />;
  }

  renderDone() {
    const { imported, errored } = this.state;
    return (
      <div className="main">
        We successfully imported <b>{imported}</b> investors. There were {errored.length || 'no'} errors.
        {this.renderErrors()}
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