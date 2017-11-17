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

  _getSubscription = key => {
    return this.subscriptions.get(key) || (new Map());
  };

  subscribe = (key, fn) => {
    const existing = this._getSubscription(key);
    const id = existing.size;
    const delayedFn = x => setTimeout(() => {
      if (this._getSubscription(key).has(id)) {
        fn(x);
      }
    }, 0);
    existing.set(id, delayedFn);
    this.subscriptions.set(key, existing);

    const value = this.get(key);
    if (value)
      fn(value);

    return {key, id};
  };

  unsubscribe = ({key, id}) => {
    const existing = this.subscriptions.get(key);
    existing.delete(id);
    if (existing.size === 0) {
      this.subscriptions.delete(key);
    } else {
      this.subscriptions.set(key, existing);
    }
  };
}

const Singleton = new Store();
export default Singleton;