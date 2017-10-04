import Handsontable from 'handsontable-pro';
import 'handsontable-pro/dist/handsontable.full.css';
import {buildQuery, ffetch, flash, fullName} from './utils';

const IntroRequested = "<span class='faded'>Intro Requested</span>";
const RequestIntro = "<div class='text-center'><a class='button small intro-button'>Request Intro</a></div>";

let setColourClassName = function(instance, td, row) {
  let i = instance.getColHeader().indexOf('Status');
  let stage = (instance.getDataAtCell(row, i) || '').substring(2);
  $(td).addClass(`stage-${stage}`);
};

let ColourTextRenderer = function(instance, td, row, col, prop, value, cellProperties) {
  Handsontable.renderers.TextRenderer.apply(this, arguments);
  setColourClassName(instance, td, row);
};

let RequestableRenderer = function(hasPath, requestedPath, requestPath) {
  return function(instance, td, row, col, prop, value, cellProperties) {
    let sourceRow = instance.getSourceDataAtRow(row);
    if (!value) {
      let $td = $(td);
      if (_.get(sourceRow, requestedPath)) {
        td.innerHTML = IntroRequested;
      } else if (_.get(sourceRow, hasPath)) {
        let $el = $(RequestIntro);
        $el.click(() => {
          td.innerHTML = IntroRequested;
          _.set(sourceRow, requestedPath, true);
          instance.render();
          ffetch(requestPath, 'POST', {
            intro_request: {
              founder_id: gon.founder.id,
              company_id: gon.founder.primary_company.id,
              investor_id: sourceRow.investor_id,
            },
          }).then(() => flash(`Requested intro to ${fullName(sourceRow)}!`));
        });
        $td.empty().append($el);
      } else {
        td.innerHTML = "";
      }
    } else {
      Handsontable.renderers.TextRenderer.apply(this, arguments);
    }
    setColourClassName(instance, td, row);
  };
};

let ButtonRenderer = function(text, onClick) {
  return function(instance, td, row, col, prop, value, cellProperties) {
    let sourceRow = instance.getSourceDataAtRow(row);
    if (!sourceRow.id) {
      td.innerHTML = "";
      return;
    }
    let $el = $(`<div class='text-center'><a class='button small intro-button'>${text}</a></div>`);
    $el.click(() => onClick(row));
    $(td).empty().append($el);
    setColourClassName(instance, td, row);
  };
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

export let autocomplete = function(translate, inverse, path) {
  let data = (row, val) => {
    if (typeof val !== 'undefined') {
      _.set(row, path, inverse[val]);
    } else {
      return _.get(row, path, "");
    }
  };
  data.path = path;
  data.inverse = inverse;
  return {
    data,
    ...makeAutocompleteOptions(translate, inverse),
  };
};

export let simple = path => ({data: path, renderer: ColourTextRenderer});
export let button = (text, fn) => ({renderer: ButtonRenderer(text, fn)});

export let requestable = function(path, hasPath, requestedPath, requestPath) {
  return {
    data: path,
    renderer: RequestableRenderer(hasPath, requestedPath, requestPath),
  }
};

export let lazyAutocomplete = function(path, fields, field, remoteField = null) {
  remoteField = remoteField || field;
  let source = (q, process) => {
    let selected = this.hot.getSelected();
    let row = this.getRow(selected[0]);
    _.set(row, field, q);
    let query = buildQuery(row, fields);
    if (!query) {
      return;
    }
    ffetch(`${path}?${query}&pluck=${remoteField}`).then(process);
  };
  return {
    type: 'autocomplete',
    source,
    ...simple(field)
  };
};

export let nested = (fn, path, count) => {
  let paths = _.map(_.range(count), i => `${path}[${i}]`);
  paths.path = path;
  let arr = _.map(paths, p => {
    let result = fn(p);
    result.data.base = path;
    return result;
  });
  arr.paths = paths;
  return arr;
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

export let extractSchema = (columns) =>
  _.fromPairs(_.map(columns, prop => {
    let path = propToPath(prop);
    if (Array.isArray(path)) {
      return [path.path, _.times(path.length, _.constant(null))];
    } else {
      return [path, null];
    }
  }));

export let flattenedColumns = (columns) => _.flatMap(Object.values(columns), _.castArray);

export let propToPath = (prop) => {
  if (Array.isArray(prop)) {
    return prop.paths;
  } else if (typeof prop.data === 'function') {
    return prop.data.path;
  } else {
    return prop.data;
  }
};