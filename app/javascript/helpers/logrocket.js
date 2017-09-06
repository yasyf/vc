import Raven from 'raven-js';
import LogRocket from 'logrocket';
require('logrocket-react')(LogRocket);

if (window.LogRocketKey) {
  LogRocket.init(window.LogRocketKey);
}

Raven.setDataCallback(data => {
  data.extra.sessionURL = LogRocket.sessionURL;
  return data;
});

LogRocket.identify(gon.user_context.id, gon.user_context);