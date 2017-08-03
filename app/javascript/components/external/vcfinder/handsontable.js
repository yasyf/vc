import Handsontable from 'handsontable-pro';
import 'handsontable-pro/dist/handsontable.full.css';
import {ffetch} from './utils';

let setColourClassName = function(instance, td, row) {
  let i = instance.getColHeader().indexOf('Status');
  let stage = (instance.getDataAtCell(row, i) || '').substring(2);
  td.className = `stage-${stage}`;
};

let ColourTextRenderer = function(instance, td, row, col, prop, value, cellProperties) {
  Handsontable.renderers.TextRenderer.apply(this, arguments);
  setColourClassName(instance, td, row);
};

let makeColourAutocomplete = function(translate) {
  let renderer = function(instance, td, row, col, prop, value, cellProperties) {
    arguments[5] = translate[arguments[5]] || arguments[5];
    Handsontable.renderers.AutocompleteRenderer.apply(this, arguments);
    setColourClassName(instance, td, row);
  };

  let prototype = Handsontable.editors.AutocompleteEditor.prototype;
  let editor = prototype.extend();

  editor.prototype.setValue = function(value) {
    arguments[0] = translate[arguments[0]] || arguments[0];
    prototype.setValue.apply(this, arguments);
  };

  return {renderer, editor};
};

let makeAutocompleteOptions = function(translate, inverse) {
  return {
    type: 'autocomplete',
    strict: true,
    allowInvalid: false,
    source: Object.keys(inverse).concat([""]),
    ...makeColourAutocomplete(translate)
  };
};

export let autocompleteDeep = function(translate, inverse, path) {
  let data = (row, val) => {
    if (typeof val !== 'undefined') {
      _.set(row, `investor.${path}`, inverse[val]);
    } else {
      let raw = _.get(row, `investor.${path}`) || _.get(row, `investor.competitor.${path}`);
      return translate[raw] || "";
    }
  };
  data.path = path;
  data.inverse = inverse;
  return {
    data,
    ...makeAutocompleteOptions(translate, inverse),
  };
};

export let autocomplete = function(translate, inverse, path) {
  let data = (row, val) => val ? _.set(row, path, inverse[val]) : _.get(row, path, "");
  data.path = path;
  data.inverse = inverse;
  return {
    data,
    ...makeAutocompleteOptions(translate, inverse),
  };
};

export let simple = path => ({data: path, renderer: ColourTextRenderer});

export let lazyAutocomplete = function(path, fields, field) {
  let source = (q, process) => {
    let selected = this.hot.getSelected();
    let row = this.hot.getSourceDataAtRow(selected[0]);
    _.set(row, field, q);
    let query = _.compact(_.map(Object.entries(fields), ([k, v]) => {
      let val = _.get(row, v);
      if (val) {
        return `${k}=${_.get(row, v)}`;
      } else {
        return null;
      }
    }));
    console.log(query);
    if (!query.length) {
      return;
    }
    ffetch(`${path}?${query.join('&')}&pluck=${field}`).then(process);
  };
  return {
    type: 'autocomplete',
    source,
    ...simple(field)
  };
};

export let nestedHeaders = (columns) =>
  Object.entries(columns).map(([header, col]) => {
    if (Array.isArray(col)) {
      return {label: header, colspan: col.length};
    } else {
      return header;
    }
  });

export let flattenedHeaders = (columns) =>
  _.flatMap(Object.entries(columns), ([header, col]) => {
    if (Array.isArray(col)) {
      return (new Array(col.length)).fill(header);
    } else {
      return [header];
    }
  });

export let flattenedColumns = (columns) => _.flatMap(Object.values(columns), _.castArray);