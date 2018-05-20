import numpy as np
import warnings

warnings.filterwarnings(action="ignore", module="scipy", message="^internal gelsd")

def get_dataset(module):
  return np.array(module.data)

def get_datasets(modules):
  return {m.__name__.split('.')[-1]: get_dataset(m) for m in modules}

def for_each_dataset(datasets, fn):
  for n, a in datasets.items():
    print('{name}: {value}'.format(name=n, value=fn(a)))

def tuples_to_XY(tuples):
  return map(lambda x: np.array(x, dtype=np.float64), zip(*tuples))
