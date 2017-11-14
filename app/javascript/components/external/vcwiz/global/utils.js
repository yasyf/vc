import React from 'react';
import 'whatwg-fetch';
import update from 'immutability-helper';
import parseDomain from 'parse-domain';
import Dimensions from 'react-dimensions';
import Storage from './storage.js.erb';
import { FounderEventNames, FounderEventPath } from './constants.js.erb';

export const _ffetch = function(path, data, opts) {
  if (opts.form) {
    delete opts.form;
    let formData = new FormData();
    Object.entries(data || {}).forEach(([k, v]) => {
      formData.append(k, v);
    });
    opts.body = formData;
  } else if (data) {
    opts.body = JSON.stringify(data);
    opts.headers['Content-Type'] = 'application/json';
  } else if (opts.method === 'GET' && opts.cache) {
    delete opts.cache;
    const cached = Storage.getExpr(path);
    if (cached) {
      return new Promise(cb => cb(cached));
    } else {
      return fetch(path, opts).then(resp => resp.json()).then(res => {
        Storage.setExpr(path, res, 3600);
        return res;
      });
    }
  }

  return fetch(path, opts).then(resp => resp.json());
};

export const ffetch = function(path, method = 'GET', data = null, opts = {}) {
  const allOpts = {
    ...opts,
    credentials: 'same-origin',
    headers: {
      'X-CSRF-Token': csrfToken(),
    },
    method,
  };
  return _ffetch(path, data, allOpts);
};

export const ffetchCached = function(path) {
  return ffetch(path, 'GET', null, {cache: true});
};

export const ffetchPublic = function(path, method = 'GET', data = null, opts = {}) {
  const allOpts = {...opts, method};
  return _ffetch(path, data, allOpts);
};

export const flush = function() {
  setTimeout(() => Storage.clearExpr(), 0);
};

export const csrfToken = function() {
  return window.gon.csrfToken;
};

export const isLoggedIn = function() {
  return !!window.gon.founder;
};

export const isDRF = function() {
  return window.gon.founder['drf?'];
};

export const isMe = function(founder) {
  return window.gon.founder.id === founder.id;
};

export const fullName = function(founder) {
  return `${founder.first_name} ${founder.last_name}`;
};

export const initials = function(founder) {
  return `${_.first(founder.first_name) || ''}${_.first(founder.last_name) || ''}`;
};

export const wordJoin = function(words) {
  if (words.length === 1) {
    return words[0];
  } else if (words.length === 2) {
    return words.join(' and ');
  } else {
    return `${_.initial(words).join(', ')}, and ${_.last(words)}`;
  }
};

export const pronoun = function(gender, tense = null) {
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
    if (v !== undefined && (overwrite || _.isEmpty(ret[k]))) {
      ret[k] = v;
    }
  });
  return ret;
};

export const extend = (dest, src) => _extend(dest, src, true);
export const merge = (dest, src) => _extend(dest, src, false);

export const emplace = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return [update(items, {[index]: {$set: item}}), index];
};

export const extract = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return update(items, {$unset: [index]});
};

export const remove = function(items, item) {
  let index = _.findIndex(items, {id: item.id});
  return update(items, {$splice: [[index, 1]]});
};

export const buildQuery = (row, context = '') => {
  const keys = Object.keys(row);
  keys.sort();
  return _.compact(_.map(keys, k => {
    let val = _.get(row, k);
    if (_.isObjectLike(val)) {
      return buildQuery(val, k);
    }
    if (nullOrUndef(val) || val === "" || val === 0) {
      return null;
    } else if (context) {
      return `${context}[${k}]=${val}`;
    } else {
      return `${k}=${val}`;
    }
  })).join('&')
};

export const nullOrUndef = (val) => val === undefined || val === null;

export const getDomain = (url) => {
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

export const timestamp = () => Date.now();
export const flattenFilters = filters => _.pickBy(_.mapValues(filters, f => _.map(f, 'value').join(',')), Boolean);
export const dots = n => _.times(n, i => <span key={`dot-${i}`} className="dot">·</span>);
export const withDots = a => _.flatMap(_.zip(a, dots(a.length - 1)));

export const withDims = klass => Dimensions({elementResize: true})(klass);

export const imageExists = url => {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.onload = resolve;
    img.onerror = reject;
    img.src = url;
  });
};

export const currentPage = () => {
  return window.location.pathname + window.location.search;
};

export const replaceSort = (key, direction, oldSort) => {
  const keys = Object.keys(oldSort);
  const base = _.zipObject(keys, _.times(keys.length, _.constant(0)));
  return extend(base, {[key]: direction});
};

export const sendEvent = (name, ...args) => {
  if (!isLoggedIn()) {
    return;
  }
  if (!FounderEventNames.includes(name)) {
    throw new Error(`invalid event ${name}`);
  }
  return ffetch(FounderEventPath, 'POST', {event: {name, args}});
};

export const withoutIndexes = (arr, idxs) => {
  const newArr = [...arr];
  _.pullAt(newArr, idxs);
  return newArr;
};