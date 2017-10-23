export default {
  get: key => window.sessionStorage && JSON.parse(window.sessionStorage.getItem(key)),
  set: (key, value) => window.sessionStorage && window.sessionStorage.setItem(key, JSON.stringify(value)),
};