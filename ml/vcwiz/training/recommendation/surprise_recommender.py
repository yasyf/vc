from surprise import Reader, Dataset, evaluate, print_perf
from surprise.prediction_algorithms.algo_base import AlgoBase
from surprise.dump import dump, load
from operator import attrgetter
from itertools import islice

class SurpriseRecommender(object):
  def __init__(self, algo: AlgoBase, path: str=None, fmt='user item rating', sep=','):
    self.algo = algo
    if path:
      self.data = Dataset.load_from_file(path, reader=Reader(line_format=fmt, sep=sep, skip_lines=1))
    else:
      self.data = None
    self.trainset = None

    self.init()

  def init(self, n=5):
    self.data.split(n_folds=n)

  def evaluate(self):
    print_perf(self.metrics(None))

  def train(self):
    self.trainset = self.data.build_full_trainset()
    self.algo.train(self.trainset)

  def predict(self, user, investor):
    return self.algo.predict(user, investor)

  def top_n(self, uid: str, n=10, user_items=None):
    items = set(user_items) or {
      iid
      for (iid, _) in self.trainset.ur[self.trainset.to_inner_uid(uid)]
    }
    tetset = [
      (uid, self.trainset.to_raw_iid(i), self.trainset.global_mean)
      for i in self.trainset.all_items()
      if i not in items
    ]
    predictions = self.algo.test(tetset)
    sorted_predictions = sorted(predictions, key=attrgetter('est'), reverse=True)
    iids = map(attrgetter('iid'), sorted_predictions)
    return islice(iids, n)

  def metrics(self, measures):
    return evaluate(self.algo, self.data, measures=measures)

  def save(self, filename):
    dump(filename, algo=self.algo)

  @classmethod
  def load(cls, filename):
    _, algo = load(filename)
    return cls(algo)
