import LogRocket from 'logrocket';
require('logrocket-react')(LogRocket);

if (window.LogRocketKey) {
  LogRocket.init(window.LogRocketKey);
}

LogRocket.identify(gon.userContext.id, gon.userContext);