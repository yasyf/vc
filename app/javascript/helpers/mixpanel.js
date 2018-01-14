mixpanel.identify(gon.userContext.id);
mixpanel.people.set(gon.userContext);

if (window.LogRocket) {
  LogRocket.getSessionURL(function (sessionURL) {
    mixpanel.track('LogRocket', { sessionURL: sessionURL });
  });
}