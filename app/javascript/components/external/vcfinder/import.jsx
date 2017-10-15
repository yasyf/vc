import React from 'react';
import Select from 'react-select';
import Modal from 'react-modal';
import {ffetch} from './utils';
import update from 'immutability-helper';
import {TargetInvestorsBulkImportPath, ImportHeadersOptions} from './constants.js.erb';

const State = {
  START: 'START',
  LOADED: 'LOADED',
  IMPORTING: 'IMPORTING',
};

export default class Import extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      headers: {},
      samples: [],
      state: State.START,
      open: false,
    };
  }

  onImport = () => {
    this.setState({state: State.IMPORTING});
    ffetch(TargetInvestorsBulkImportPath, 'POST', {
      headers: this.state.headers,
    }).then(targets => {
      this.props.onImport(targets);
      this.onCloseModal();
    });
  };

  onCloseModal = () => {
    this.setState({open: false});
  };

  onOpenModal = () => {
    this.setState({open: true});
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

  onFileUpload = (e) => {
    ffetch(TargetInvestorsBulkImportPath, 'POST', {
      csv_file: e.target.files[0],
    }, true).then(({error, message, suggestions, samples}) => {
      if (error) {
        console.log(message);
      } else {
        this.setState({state: State.LOADED, samples, headers: suggestions});
      }
    });
  };

  options(i) {
    let used = Object.values(this.state.headers);
    let options = _.reject(ImportHeadersOptions, o => used.includes(o.value));
    if (this.state.headers[i]) {
      options.push(_.find(ImportHeadersOptions, {value: this.state.headers[i]}));
    }
    return options;
  }

  renderForm() {
    let input = (
      <label>
        Import CSV:
        <input type="file" accept=".csv" name="csv_file" onChange={this.onFileUpload} />
      </label>
    );

    let button = (
      <button type="button" className="button" onClick={this.onImport}>
        Import!
      </button>
    );

    return (
      <div>
        <form>
          {this.state.state === State.LOADED ? button : input}
        </form>
      </div>
    );
  }

  renderSamples() {
    if (this.state.state !== State.LOADED) {
      return null;
    }

    let selects = _.range(this.state.samples[0].length).map(i => {
      let options = this.options(i);
      let disabled = options.length === 0;
      return (
        <th key={i} className="import-header">
          <Select
            value={this.state.headers[i]}
            options={options}
            onChange={this.onUpdateHeader(i)}
            disabled={disabled}
            placeholder={disabled ? 'All Assigned!' : 'Select Header...'}
          />
        </th>
      );
    });
    let samples = this.state.samples.map((sample, i) =>
      <tr key={i}>{sample.map((s, ii) => <td key={ii}>{s}</td>)}</tr>
    );

    return (
      <table>
        <thead>
          <tr>
            {selects}
          </tr>
        </thead>
        <tbody>
          {samples}
        </tbody>
      </table>
    );
  }

  renderModal() {
    if (this.state.state === State.IMPORTING) {
      return <p>Importing...</p>
    }
    return (
      <div className="float-center investor">
        {this.renderForm()}
        {this.renderSamples()}
      </div>
    );
  }

  render() {
    return (
      <div>
        <Modal
          isOpen={this.state.open}
          onRequestClose={this.onCloseModal}
          contentLabel={'Import Investors'}
        >
          {this.renderModal()}
        </Modal>
        <div className="vcwiz-info">
          <button type="button" className="button" onClick={this.onOpenModal}>
            {'Import'}
          </button>
        </div>
      </div>
    )
  }
}