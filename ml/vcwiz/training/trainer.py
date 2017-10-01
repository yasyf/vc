from abc import  ABC, abstractmethod
import os, sys, tempfile
from google.cloud import storage

class Trainer(ABC):
  def __init__(self):
    self.model = None
    self.output_path = None
    self.upload_path = None

    self.client = storage.Client(os.environ['GC_PROJECT_ID'])
    self.bucket = self.client.bucket(os.environ['GOOGLE_MODEL_BUCKET'])

  @abstractmethod
  def _train(self, filename):
    raise NotImplementedError

  def train(self, filename):
    self.model = self._train(filename)

  def remote_train(self, path):
    file = tempfile.mkstemp(prefix=path, suffix='.csv')
    blob = self.bucket.blob(path)
    blob.download_to_filename(file.name)
    self.train(file.name)

  @abstractmethod
  def _save(self, model, path):
    raise NotImplementedError

  def save(self, path):
    assert self.model
    self._save(self.model, path)
    self.output_path = path

  def upload(self, path):
    assert self.output_path
    blob = self.bucket.blob(path)
    blob.upload_from_filename(self.output_path)
    self.upload_path = path
    return blob.generation

  def remote_save(self, path):
    file = tempfile.mkstemp(prefix=path, suffix='.model')
    self.save(file.name)
    return self.upload(path)

  @abstractmethod
  def _test(self, model, *args):
    raise NotImplementedError

  def test(self, *args):
    assert self.model
    self._test(self.model, *args)

  @classmethod
  def _train_and_test(cls, filename, args):
    instance = cls()
    instance.train(filename)
    instance.test(*args)

  @classmethod
  def train_and_test(cls):
    filename = sys.argv[1]
    args = sys.argv[2:]
    cls._train_and_test(filename, args)
