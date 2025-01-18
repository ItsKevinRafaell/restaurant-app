enum NavigationRoute {
  mainRoute("/main"),
  searchRoute("/search"),
  revieWRoute("/review"),
  detailRoute("/detail");

  const NavigationRoute(this.name);
  final String name;
}
