from surprise import SVDpp
from recommender import Recommender
import sys

def run_basic(filename, uid):
  rec = Recommender(filename, SVDpp())
  rec.train()
  print('trained')
  top = rec.top_n(uid)
  print(top)


if __name__ == '__main__':
  run_basic(sys.argv[1], sys.argv[2])
