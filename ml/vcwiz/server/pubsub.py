import os, json
from google.cloud import pubsub_v1

def subscribe(subscription, callback):
  subscriber = pubsub_v1.SubscriberClient()
  path = subscriber.subscription_path(os.environ['GC_PROJECT_ID'], subscription)
  subscriber.subscribe(path, callback=callback)

def push(topic, message):
  publisher = pubsub_v1.PublisherClient()
  path = publisher.topic_path(os.environ['GC_PROJECT_ID'], topic)
  publisher.publish(path, message)
