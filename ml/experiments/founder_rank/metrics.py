import numpy as np
import scipy.stats as stats

# dataset: [[id, score, rank]]

def dcg(a):
  size = a.shape[0]
  scale = 1.0 / np.log2(np.arange(2, (size + 1) + 1))
  relevances = np.power(2, a[:, 2]) - 1
  return scale.dot(relevances)

def dcg2(a):
  size = a.shape[0]
  scale = 1.0 / np.log2(np.arange(2, (size + 1) + 1))
  return scale.dot(a[:, 2])

class Metrics(object):
  def __init__(self, baseline, power_dcg=True):
    self.baseline = baseline
    self.dcg_fn = dcg if power_dcg else dcg2
    self.idcg = self.dcg_fn(self.baseline)

  def ndcg(self, a):
    return self.dcg_fn(a) / self.idcg

  def precision_at(self, n, a):
    desired = self.baseline[0:n, 0]
    retrieved = a[0:n, 0]
    return np.intersect1d(desired, retrieved).size / float(n)

  def tau(self, a):
    return stats.kendalltau(a[:, 2], self.baseline[:, 2])

  def rho(self, a):
    return stats.spearmanr(a[:, 2], self.baseline[:, 2])

  def rmse(self, a):
    n = a.shape[0]
    differences = np.power(a[:, 1] - self.baseline[:, 1], 2)
    return np.sqrt(np.sum(differences) / float(n))

  def mae(self, a):
    n = a.shape[0]
    differences = np.abs(a[:, 1] - self.baseline[:, 1])
    return np.sum(differences) / float(n)
