import numpy as np

def get_datasets(modules):
  return {m.__name__.split('.')[-1]: np.array(m.data) for m in modules}

def for_each_dataset(datasets, fn):
  for n, a in datasets.items():
    print('{name}: {value}'.format(name=n, value=fn(a)))
