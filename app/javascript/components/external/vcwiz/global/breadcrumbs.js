import Raven from 'raven-js';

class Breadcrumbs {
  constructor() {
    this.queue = [];
  }

  push(name, category = 'manual', params = {}) {
    this.queue.push({name, params});
    Raven.captureBreadcrumb({
      message: name,
      category: category,
      data: params,
    });
  }

  pop() {
    this.queue.pop();
  }

  replace(params) {
    this.queue[this.queue.length - 1].params = params;
    Raven.captureBreadcrumb({
      message: this.peek().name,
      category: this.peek().category,
      data: params,
    });
  }

  peek() {
    return this.queue[this.queue.length - 1];
  }
}

const Singleton = new Breadcrumbs();
export default Singleton;