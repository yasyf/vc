import Raven from 'raven-js';
import LogRocket from 'logrocket';
require('logrocket-react')(LogRocket);

if (window.LogRocketKey) {
  LogRocket.init(window.LogRocketKey);
}

LogRocket.identify(gon.userContext.id, gon.userContext);

Raven.setDataCallback(function(data) {
  data.extra.sessionURL = LogRocket.sessionURL;
  return data;
});

if (window.mixpanel) {
  LogRocket.getSessionURL(function(sessionURL) {
    mixpanel.track('LogRocket', { sessionURL: sessionURL });
  });
}