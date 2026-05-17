class Routes {
  Routes._();

  static const auth = _AuthRoutes();
  static const details = _DetailsRoutes();
  static const search = _SearchRoutes();

  static const settings = "/settings";
  static const home = "/home";
}

class _AuthRoutes {
  const _AuthRoutes();

  String get root => "/";
  String get start => "/auth/start";
  String get spotify => "/auth/spotify";
  String get youtube => "/auth/youtube";
}

class _DetailsRoutes {
  const _DetailsRoutes();

  String get player => "/details/player";
  String get playlist => "/details/playlist";
  String get artist => "/details/artist";
  String get track => "/details/track";
}

class _SearchRoutes {
  const _SearchRoutes();

  String get spotify => "/search/spotify";
  String get youtube => "/search/youtube";
}
