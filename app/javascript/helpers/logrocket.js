import Raven from 'raven-js';
import LogRocket from 'logrocket';

if (window.LogRocketKey) {
  LogRocket.init(window.LogRocketKey);
}

Raven.setDataCallback(data => {
  data.extra.sessionURL = LogRocket.sessionURL;
  return data;
});

LogRocket.identify(gon.userContext.id, gon.userContext);