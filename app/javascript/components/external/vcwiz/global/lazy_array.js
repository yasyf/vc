import {ffetch} from '../../vcfinder/utils';

const noop = bucket => {};

export default class LazyArray {
  constructor(initial, source, onUpdate = noop) {
    this.buckets = new Map([[0, initial]]);
    this.loading = new Set();
    this.bucketSize = initial.length;
    this.source = source;
    this.onUpdate = onUpdate;
  }

  fetchBucket(bucket) {
    this.loading.add(bucket);
    return ffetch(`${this.source}?limit=${this.bucketSize}&page=${bucket}`).then(vals => {
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