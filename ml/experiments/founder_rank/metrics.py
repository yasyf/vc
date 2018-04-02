import numpy as np

# a: [[id, score, rank]]

def dcg(a):
  size = a.shape[0]
  scale = 1.0 / np.log2(np.arange(2, (size + 1) + 1))
  relevances = np.power(2, a[:, 2]) - 1
  return scale.dot(relevances)

class Metrics(object):
  def __init__(self, baseline):
    self.baseline = baseline

    self.idcg = dcg(self.baseline)

  def ndcg(self, a):
    return dcg(a) / self.idcg

  def precision_at(self, n, a):
    desired = self.baseline[0:n, 0]
    retrieved = a[0:n, 0]
    return np.intersect1d(desired, retrieved).size / float(n)

  def tau(self, a):
    n = a.shape[0]
    total = 0
    for i in range(n):
      for j in range(n):
        if i == j:
          continue
        total += np.sign(a[i, 2] - a[j, 2]) * np.sign(self.baseline[i, 2] - self.baseline[j, 2])
    return total / (n * (n - 1))

  def rho(self, a):
    n = a.shape[0]
    differences = np.power(a[:, 2] - self.baseline[:, 2], 2)
    return 1 - ((6 * np.sum(differences)) / (n * (np.power(n, 2) - 1)))

  def rmse(self, a):
    n = a.shape[0]
    differences = np.power(a[:, 1] - self.baseline[:, 1], 2)
    return np.sqrt(np.sum(differences) / float(n))

  def mae(self, a):
    n = a.shape[0]
    differences = np.abs(a[:, 1] - self.baseline[:, 1])
    return np.sum(differences) / float(n)
