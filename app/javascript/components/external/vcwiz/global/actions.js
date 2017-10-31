class Actions {
  constructor() {
    this.registry = new Map();
  }

  register = (key, fn) => {
    this.registry.set(key, fn);
  };

  unregister = key => {
    this.registry.delete(key);
  };

  trigger = (key, value) => {
    const fn = this.registry.get(key);
    if (fn)
      fn(value);
  };
}

const Singleton = new Actions();
export default Singleton;