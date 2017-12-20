import React from 'react';
import 'whatwg-fetch';
import parseDomain from 'parse-domain';
import Dimensions from 'react-dimensions';
import { LocalStorage, SessionStorage } from './storage.js.erb';
import { FounderEventNames, FounderEventPath, StorageRestoreStateKey, MobileScreenSize } from './constants.js.erb';
import Breadcrumb from './breadcrumbs';
import Store from './store';
import { canUseDOM } from 'exenv';

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
    const cached = LocalStorage.getExpr(path);
    if (cached) {
      return new Promise(cb => cb(cached));
    } else {
      return fetch(path, opts).then(resp => resp.json()).then(res => {
        LocalStorage.setExpr(path, res, 3600);
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

export const flush = function() {
  setTimeout(() => LocalStorage.clearExpr(), 0);
};

export const csrfToken = function() {
  return window.gon.csrfToken;
};

export const isLoggedIn = function() {
  return !!window.gon.founder;
};

export const fullName = function(founder) {
  return `${founder.first_name} ${founder.last_name}`;
};

export const initials = function(founder) {
  return `${_.first(founder.first_name) || ''}${_.first(founder.last_name) || ''}`;
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

export const getDomain = (url, withSubdomain = true) => {
  if (!url) {
    return null;
  }
  let parts = parseDomain(url);
  if (!parts) {
    return null;
  } else {
    return _.compact([withSubdomain ? parts.subdomain : null, parts.domain, parts.tld]).join('.');
  }
};

export const timestamp = () => Date.now();
export const flattenFilters = filters => _.pickBy(_.mapValues(filters, f => _.uniq(_.map(f, 'value')).join(',')), Boolean);
export const withSeparators = (sepFn, a) => _.flatMap(_.zip(a, _.times(a.length - 1, sepFn)));
export const withDots = a => withSeparators(i => <span key={`dot-${i}`} className="dot">·</span>, a);

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

const filterOptionMatches = (value, filterValue) => value.toLowerCase().indexOf(filterValue) >= 0;

export const filterOption = (option, filterValue) => {
  if (!filterValue) return true;
  const value = String(option.value);
  const label = String(option.label);
  const otherLabels = option.other_labels;
  return (
    filterOptionMatches(value, filterValue) ||
    filterOptionMatches(label, filterValue) ||
    (otherLabels && _.some(otherLabels, ov => filterOptionMatches(ov, filterValue)))
  );
};

export const humanizeList = list => {
  if (list.length === 1) {
    return _.first(list);
  } else if (list.length === 2) {
    return [<span key="first">{_.first(list)}</span>, <span key="and"> and </span>, <span key="last">{_.last(list)}</span>];
  } else {
    const initial = _.flatMap(_.initial(list), (s, i) => [<span key={`s-${i}`}>{s}</span>, <span key={`comma-${i}`}>, </span>]);
    return initial.concat([<span key="and"> and </span>, <span key="last">{_.last(list)}</span>]);
  }
};

export const humanizeTravelStatus = (travelStatus, openCity) => {
  switch (travelStatus) {
    case 'working':
      return `hard at work in ${openCity}`;
    case 'work_traveling':
      return `travelling for work in ${openCity}`;
    case 'pleasure_traveling':
      return `taking a vacation in ${openCity}`;
  }
};

export const saveCurrentRestoreState = () => {
  SessionStorage.set(StorageRestoreStateKey, {
    breadcrumb: Breadcrumb.peek(),
    location: currentPage(),
  });
};

export const toOptions = (arr, options) => arr.map(x => ({value: x, label: options[x]}));
export const isMobile = () => canUseDOM && document.documentElement.clientWidth <= MobileScreenSize;

export const preloadImage = path => {
  const preload = document.createElement("link");
  preload.href = path;
  preload.rel = 'preload';
  preload.as = 'image';
  document.head.appendChild(preload);
};
export const preloadImages = images => images.forEach(preloadImage);