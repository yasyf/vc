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

  fetchBucket(bucket) {
    this.loading.add(bucket);
    let {path, query} = this.source;
    query = {limit: this.bucketSize, page: bucket, ...(query || {})};
    return ffetch(`${path}?${buildQuery(query)}`).then(vals => {
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
    let bucket = Math.floor(index / this.bucketSize);
    let bucketIndex = index - bucket * this.bucketSize;

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
    let bucket = Math.floor(index / this.bucketSize);
    let bucketIndex = index - bucket * this.bucketSize;

    if (this.buckets.has(bucket)) {
      return new Promise(cb => cb(this.buckets.get(bucket)[bucketIndex]));
    } else if (this.loading.has(bucket)) {
      return new Promise(cb => this.pollBucket(bucket, bucketIndex, cb));
    } else {
      this.fetchBucket(bucket).then(() => this.buckets.get(bucket)[bucketIndex]);
    }
  }
}