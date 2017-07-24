let UserContext = {
  id: (gon.founder && gon.founder.id) || (gon.user && gon.user.id),
  name: (gon.founder && `${gon.founder.first_name} ${gon.founder.last_name}`) || (gon.user && gon.user.name),
  email: (gon.founder && gon.founder.email) || (gon.user && gon.user.email)
};

export default UserContext;