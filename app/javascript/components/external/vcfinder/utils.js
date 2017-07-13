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
  return fetch(path, opts);
};

export let isDRF = function() {
  return gon.founder['drf?'];
}