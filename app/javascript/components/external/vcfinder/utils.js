import React from 'react';
import 'whatwg-fetch';
import update from 'immutability-helper';
import { toast } from 'react-toastify';

export let ffetch = function(path, method = 'GET', data = null) {
  let opts = {
    credentials: 'same-origin',
    headers: {
      'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
      'Content-Type': 'application/json',
    },
    method,
  };
  if (data)
    opts['body'] = JSON.stringify(data);
  return fetch(path, opts).then(resp => resp.json());
};

export let isDRF = function() {
  return gon.founder['drf?'];
};

export let isMe = function(founder) {
  return gon.founder.id === founder.id;
};

export let fullName = function(founder) {
  return `${founder.first_name} ${founder.last_name}`;
};

let _extend = function(dest, src, overwrite = true) {
  let ret = Object.assign({}, dest);
  Object.entries(src).forEach(([k, v]) => {
    if (ret.hasOwnProperty(k) && v !== undefined && (overwrite || ret[k] === null)) {
      ret[k] = v;
    }
  });
  return ret;
};

export let extend = (dest, src) => _extend(dest, src, true);
export let merge = (dest, src) => _extend(dest, src, false);

export let emplace = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return update(items, {[index]: {$set: item}});
};

export let extract = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return update(items, {$unset: [index]});
};

export let pluckSort = function(objects, prop, keys) {
  return _.sortBy(_.uniq(_.map(objects, prop)), s => keys.indexOf(s));
};

export let onChangeSet = (item, path, cb) =>
  (ev) => cb(update(item, _.set({}, path, {$set: ev.target.value})));

export let flash = (text) => toast(text);

export let buildQuery = (fields, row) =>
  _.compact(_.map(fields, k => {
    let val = _.get(row, k);
    return !val ? null : `${k}=${val}`;
  }));

export let nullOrUndef = (val) => val === undefined || val === null;