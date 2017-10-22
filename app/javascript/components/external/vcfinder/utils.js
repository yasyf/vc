import React from 'react';
import 'whatwg-fetch';
import update from 'immutability-helper';
import parseDomain from 'parse-domain';
import {StoragePrefix} from './constants.js.erb';

export let ffetch = function(path, method = 'GET', data = null, form = false) {
  let opts = {
    credentials: 'same-origin',
    headers: {
      'X-CSRF-Token': window.gon.csrfToken,
    },
    method,
  };

  if (form) {
    let formData = new FormData();
    Object.entries(data || {}).forEach(([k, v]) => {
      formData.append(k, v);
    });
    opts['body'] = formData;
  } else if (data) {
    opts['body'] = JSON.stringify(data);
    opts['headers']['Content-Type'] = 'application/json';
  }

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

export let wordJoin = function(words) {
  if (words.length === 1) {
    return words[0];
  } else if (words.length === 2) {
    return words.join(' and ');
  } else {
    return `${_.initial(words).join(', ')}, and ${_.last(words)}`;
  }
};

export let pronoun = function(gender, tense = null) {
  if (gender === 'male') {
    return (tense === 'pos') ? 'his' : (tense === 'past') ? 'him' : 'he';
  } else if (gender === 'female') {
    return (tense === 'pos') ? 'her' : (tense === 'past') ? 'her' : 'she';
  } else {
    return (tense === 'pos') ? 'their' : (tense === 'past') ? 'them' : 'they';
  }
};

let _extend = function(dest, src, overwrite = true) {
  let ret = Object.assign({}, dest);
  Object.entries(src).forEach(([k, v]) => {
    if (v !== undefined && (overwrite || ret[k] === null)) {
      ret[k] = v;
    }
  });
  return ret;
};

export let extend = (dest, src) => _extend(dest, src, true);
export let merge = (dest, src) => _extend(dest, src, false);

export let emplace = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return [update(items, {[index]: {$set: item}}), index];
};

export let extract = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return update(items, {$unset: [index]});
};

export let remove = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return update(items, {$splice: [[index, 1]]});
};

export let pluckSort = function(objects, prop, keys) {
  return _.sortBy(_.uniq(_.map(objects, prop)), s => keys.indexOf(s));
};

export let onChangeSet = (item, path, cb) =>
  (ev) => cb(update(item, _.set({}, path, {$set: ev.target.value})));

export let flash = (text) => toast(text);

export let buildQuery = (row, fields = null) =>
  _.compact(_.map(fields || Object.keys(row), k => {
    let val = _.get(row, k);
    if (_.isObjectLike(val)) {
      val = JSON.stringify(val);
    }
    return (nullOrUndef(val) || val === "") ? null : `${k}=${val}`;
  }));

export let nullOrUndef = (val) => val === undefined || val === null;

export let getDomain = (url) => {
  if (!url) {
    return null;
  }
  let parts = parseDomain(url);
  if (!parts) {
    return null;
  } else {
    return _.compact([parts.subdomain, parts.domain, parts.tld]).join('.');
  }
};

export let storageKey = (key) => `${StoragePrefix}::${key}`;