from surprise import SVDpp
from .surprise_recommender import SurpriseRecommender
from ..trainer import Trainer

class Basic(Trainer):
  def _train(self, filename):
    rec = SurpriseRecommender(SVDpp(), filename)
    rec.train()
    return rec

  def _test(self, model, uid):
    top = model.top_n(uid)
    print(top)

  def _save(self, model, path):
    model.save(path)
