import {ffetch, buildQuery} from './utils';

const noop = bucket => {};
const defaultBucketSize = 20;

export default class LazyArray {
  constructor(source, initial = null, onUpdate = noop) {
    this.buckets = new Map();
    this.loading = new Set();
    this.bucketSize = (initial && initial.length) || defaultBucketSize;
    this.source = source;
    this.onUpdate = onUpdate;

    if (initial) {
      this.buckets.set(0, initial);
    }
  }

  bucketFromIndex(index) {
    const bucket = Math.floor(index / this.bucketSize);
    const bucketIndex = index - bucket * this.bucketSize;
    return [bucket, bucketIndex];
  }

  url(args = {}) {
    let {path, query} = this.source;
    query = {...args, ...(query || {})};
    return `${path}?${buildQuery(query)}`;
  }

  urlWithId(id) {
    const {path, query} = this.source;
    return `${path.id(id)}?${buildQuery(query || {})}`;
  }

  dup() {
    const la = new LazyArray(this.source, null, this.onUpdate);
    la.buckets = _.clone(this.buckets);
    la.bucketSize = this.bucketSize;
    return la;
  }

  fetchBucket(bucket) {
    this.loading.add(bucket);
    return ffetch(this.url({limit: this.bucketSize, page: bucket})).then(vals => {
      this.buckets.set(bucket, vals);
      this.loading.delete(bucket);
      this.onUpdate(bucket);
    });
  }

  pollBucket(bucket, bucketIndex, cb) {
    let interval = setInterval(() => {
      if (this.buckets.has(bucket)) {
        clearInterval(interval);
        return cb(this.buckets.get(bucket)[bucketIndex]);
      }
    }, 500);
  }

  getSync(index) {
    const [bucket, bucketIndex] = this.bucketFromIndex(index);

    if (this.buckets.has(bucket)) {
      return this.buckets.get(bucket)[bucketIndex];
    } else if (this.loading.has(bucket)) {
      return null;
    } else {
      this.fetchBucket(bucket);
      return null;
    }
  }

  get(index) {
    const [bucket, bucketIndex] = this.bucketFromIndex(index);

    if (this.buckets.has(bucket)) {
      return new Promise(cb => cb(this.buckets.get(bucket)[bucketIndex]));
    } else if (this.loading.has(bucket)) {
      return new Promise(cb => this.pollBucket(bucket, bucketIndex, cb));
    } else {
      this.fetchBucket(bucket).then(() => this.buckets.get(bucket)[bucketIndex]);
    }
  }

  set(index, update, id = 'id') {
    const [bucket, bucketIndex] = this.bucketFromIndex(index);
    if (!this.buckets.has(bucket)) {
      throw `missing bucket ${bucket}!`;
    }
    const row = this.buckets.get(bucket)[bucketIndex];
    Object.entries(update).forEach(([k, v]) => {
      _.set(row, k, v);
    });
    ffetch(this.urlWithId(row[id]), 'PATCH', update).then(resp => {
      this.buckets.get(bucket)[bucketIndex] = resp;
      this.onUpdate(bucket);
    });
    return this;
  }
}