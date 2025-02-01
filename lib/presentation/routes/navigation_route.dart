enum NavigationRoute {
  mainRoute("/main"),
  searchRoute("/search"),
  revieWRoute("/review"),
  favoriteRoute("/favorite"),
  settingRoute("/setting"),
  reviewRoute("/review"),
  detailRoute("/detail");

  const NavigationRoute(this.name);
  final String name;
}
