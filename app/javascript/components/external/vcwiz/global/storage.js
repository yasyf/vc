const StorageMock = {
  get: _.noop,
  set: _.noop,
  getExpr: _.noop,
  setExpr: _.noop,
};

const Storage = {
  get: key => JSON.parse(window.sessionStorage.getItem(key)),
  remove: key => window.sessionStorage.setItem(key, null),
  set: (key, value) => window.sessionStorage.setItem(key, JSON.stringify(value)),
  getExpr: key => {
    const got = Storage.get(key);
    if (got === null || got === undefined || got.value === undefined) {
      return null;
    }
    const {value, expr} = got;
    if (expr > Date.now()) {
      return value;
    } else {
      Storage.remove(key);
      return null;
    }
  },
  setExpr: (key, value, expr) => {
    try {
      Storage.set(key, {value, expr: Date.now() + (expr * 1000)});
      return true;
    } catch (e) {
      Storage.clearExpr();
      return false;
    }
  },
  clearExpr: () => {
    Object.keys(window.sessionStorage).forEach(key => {
      const got = Storage.get(key);
      if (got && got.expr) {
        Storage.remove(key);
      }
    });
  },
};



export default window.sessionStorage ? Storage : StorageMock;