class Store {
  constructor() {
    this.store = new Map();
    this.subscriptions = new Map();
  }

  set = (key, value) => {
    this.store.set(key, value);
    if (this.subscriptions.has(key)) {
      this.subscriptions.get(key).forEach(fn => {
        if (fn)
          fn(value);
      });
    }
  };

  get = (key, _default = null) => {
    return this.store.get(key) || _default;
  };

  subscribe = (key, fn) => {
    const existing = this.subscriptions.get(key) || [];
    const id = existing.length;
    this.subscriptions.set(key, existing.concat([fn]));

    const value = this.get(key);
    if (value)
      fn(value);

    return {key, id};
  };

  unsubscribe = ({key, id}) => {
    const existing = this.subscriptions.get(key);
    existing[id] = null;
    if (_.compact(existing).length === 0) {
      this.subscriptions.delete(key);
    } else {
      this.subscriptions.set(key, existing);
    }
  };
}

const Singleton = new Store();
export default Singleton;