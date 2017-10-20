import React from 'react';
import 'whatwg-fetch';
import update from 'immutability-helper';
import parseDomain from 'parse-domain';
import {StoragePrefix} from './constants.js.erb';

export const _ffetch = function(path, opts, data, form) {
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

export const ffetch = function(path, method = 'GET', data = null, form = false) {
  const opts = {
    credentials: 'same-origin',
    headers: {
      'X-CSRF-Token': $('meta[name=csrf-token]').attr('content'),
    },
    method,
  };
  return _ffetch(path, opts, data, form);
};

export const ffetchPublic = function(path, method = 'GET', data = null, form = false) {
  const opts = {method};
  return _ffetch(path, opts, data, form);
};

export const isDRF = function() {
  return gon.founder['drf?'];
};

export const isMe = function(founder) {
  return gon.founder.id === founder.id;
};

export const fullName = function(founder) {
  return `${founder.first_name} ${founder.last_name}`;
};

export const initials = function(founder) {
  return `${_.first(founder.first_name)}${_.first(founder.last_name)}`;
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
    if (v !== undefined && (overwrite || ret[k] === null)) {
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

export const buildQuery = (row, fields = null) =>
  _.compact(_.map(fields || Object.keys(row), k => {
    let val = _.get(row, k);
    if (_.isObjectLike(val)) {
      val = JSON.stringify(val);
    }
    return (nullOrUndef(val) || val === "") ? null : `${k}=${val}`;
  })).join('&');

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

export const storageKey = (key) => `${StoragePrefix}::${key}`;
export const timestamp = () => Date.now();
export const flattenFilters = filters => _.mapValues(filters, f => _.map(f, 'value').join(','));
export const dots = n => _.times(n, i => <span key={`dot-${i}`} className="dot">·</span>);
export const withDots = a => _.flatMap(_.zip(a, dots(a.length - 1)));