class Store {
  constructor() {
    this.registry = new Map();
  }

  register = (key, fn) => {
    this.registry.set(key, fn);
  };

  unregister = key => {
    this.registry.delete(key);
  };

  trigger = key => {
    const fn = this.registry.get(key);
    if (fn)
      fn();
  };
}

const Singleton = new Store();
export default Singleton;