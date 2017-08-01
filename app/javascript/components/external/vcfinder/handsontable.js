import Handsontable from 'handsontable-pro';

let setColourClassName = function(instance, td, row) {
  let stage = (instance.getDataAtCell(row, 4) || '').substring(2);
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

let makeAutocompleteOptions = function(translate) {
  return {
    type: 'autocomplete',
    strict: true,
    allowInvalid: false,
    ...makeColourAutocomplete(translate)
  };
};

export let autocompleteDeep = function(translate, inverse, path) {
  return {
    data: (row, val) => {
      if (val) {
        _.set(row, `investor.${path}`, inverse[val]);
      } else {
        return translate[_.get(row, `investor.${path}`) || _.get(row, `investor.competitor.${path}`)];
      }
    },
    source: Object.keys(inverse),
    ...makeAutocompleteOptions(translate),
  };
};

export let autocomplete = function(translate, inverse, path) {
  return {
    data: (row, val) => val ? _.set(row, path, inverse[val]) : _.get(row, path),
    source: Object.keys(inverse),
    ...makeAutocompleteOptions(translate),
  };
};

export let simple = path => ({data: path, renderer: ColourTextRenderer});