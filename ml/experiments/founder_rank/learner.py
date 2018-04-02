import numpy as np

class Learner(object):
  def __init__(self, baseline):
    self.baseline = baseline[:, 0:2]
    self.scores = {x[0]: x[1] for x in self.baseline}

  def _gen_XY(self, dataset):
    ids = dataset[:, 0]
    X = dataset[:, 1:]
    Y = np.array([self.scores[i] for i in ids])
    return X, Y


