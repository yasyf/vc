import React from 'react';
import Select from 'react-select';
import Modal from 'react-modal';
import {ffetch} from './utils';
import {TargetInvestorsBulkImportPath, ImportHeadersOptions} from './constants.js.erb';

export default class Import extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      headers: {},
      samples: [],
      loaded: false,
      open: false,
    };
  }

  onImport = () => {
    ffetch(TargetInvestorsBulkImportPath, 'POST', {file: "/Users/yasyf/Downloads/Master Investor Spreadsheet - Investors.csv"}).then(({error, message, suggestions, samples}) => {
      if (error) {
        console.log(message);
      } else {
        this.setState({loaded: true, samples, headers: suggestions});
      }
    });
  };

  onCloseModal = () => {
    this.setState({open: false});
  };

  onOpenModal = () => {
    this.setState({open: true});
  };

  options(i) {
    let used = Object.values(this.state.headers);
    let options = _.reject(ImportHeadersOptions, o => used.includes(o.value));
    if (this.state.headers[i]) {
      options.push(_.find(ImportHeadersOptions, {value: this.state.headers[i]}));
    }
    return options;
    // customize no labels left text
  }

  renderForm() {
    return (
      <div>
        <form>
          <label>
            Import CSV:
            <input type="file" />
          </label>
          <button type="button" className="button" onClick={this.onImport}>
            Import!
          </button>
        </form>
      </div>
    );
  }

  renderSamples() {
    if (!this.state.loaded) {
      return null;
    }

    let selects = _.range(this.state.samples[0].length).map(i =>
      <th key={i}>
        <Select value={this.state.headers[i]} options={this.options(i)} />
      </th>
    );

    let samples = this.state.samples.map((sample, i) =>
      <tr key={i}>
        {sample.map((s, ii) => <td key={ii}>{s}</td>)}
      </tr>
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
            Import
          </button>
        </div>
      </div>
    )
  }
}