import update from 'immutability-helper';

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