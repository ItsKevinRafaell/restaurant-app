enum NavigationRoute {
  mainRoute("/main"),
  searchRoute("/search"),
  favoriteRoute("/favorite"),
  settingRoute("/setting"),
  reviewRoute("/review"),
  detailRoute("/detail");

  const NavigationRoute(this.name);
  final String name;
}
