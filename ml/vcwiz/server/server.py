import os, json
from .pubsub import subscribe, push
from importlib import import_module

def get_trainer(model_name):
  mod = import_module('.{}'.format(model_name), 'vcwiz.training')
  return getattr(mod, model_name.split('.')[-1].title())

def train(message):
  message = json.loads(message)
  trainer = get_trainer(message['name'])()
  trainer.remote_train(message['data_path'])
  generation = trainer.remote_save(message['model_path'])
  push(os.environ['GOOGLE_MODEL_TOPIC'], json.dumps({
    'id': message['id'],
    'model_generation': generation,
    'metrics': trainer.metrics(),
  }))

def run():
  subscribe(os.environ['GOOGLE_MODEL_SUBSCRIPTION'], train)
