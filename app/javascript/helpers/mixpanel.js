if (window.mixpanel) {
  mixpanel.identify(gon.userContext.id);
  mixpanel.people.set(gon.userContext);
}