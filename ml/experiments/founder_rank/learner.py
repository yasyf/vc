import numpy as np
from sklearn import linear_model, metrics

# features: [[id, ...]]
# dataset: [[id, score, rank]]

class Learner(object):
  def __init__(self, baseline):
    self.scores = {x[0]: x[1] for x in baseline}
    self.ranks = {x[0]: x[2] for x in baseline}

  def _process_features(self, features):
    ids = features[:, 0]
    ranks = np.array([self.ranks[i] for i in ids])
    X = features[:, 1:]
    Y = np.array([self.scores[i] for i in ids])

    return ids, ranks, X, Y

  def _process_scores(self, scores, ids, ranks):
    dataset = np.stack([ids, scores, ranks], 1)
    sort_ind = dataset[:, 1].argsort()[::-1]
    return dataset[sort_ind]

  def linear_regression(self, features):
    ids, ranks, X, Y = self._process_features(features)

    model = linear_model.LinearRegression(n_jobs=-1, fit_intercept=False)
    model.fit(X, Y)
    scores = model.predict(X)

    dataset = self._process_scores(scores, ids, ranks)
    return dataset, model.coef_, metrics.r2_score(Y, scores)
