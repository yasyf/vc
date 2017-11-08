import React from 'react';

export default class Table extends React.Component {
  render() {
    const { headers, rows, headerClass } = this.props;
    const ths = _.map(headers, (header, i) =>
      <th key={i} className={headerClass}>{header}</th>
    );
    console.log(rows);
    let trs = _.map(rows, (row, i) =>
      <tr key={i}>{_.map(row, (s, ii) => <td key={ii}>{s}</td>)}</tr>
    );

    return (
      <table>
        <thead>
          <tr>
            {ths}
          </tr>
        </thead>
        <tbody>
          {trs}
        </tbody>
      </table>
    );
  }
}