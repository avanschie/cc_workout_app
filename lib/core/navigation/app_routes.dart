/// Enum defining all application routes with type-safe navigation
enum AppRoute {
  // Auth routes
  signIn('/sign-in'),
  signUp('/sign-up'),
  forgotPassword('/forgot-password'),

  // Main app routes
  home('/'),
  repMaxes('/rep-maxes'),
  history('/history'),
  addLift('/add-lift'),
  editLift('/edit-lift/:id');

  const AppRoute(this.path);

  final String path;
}

/// Extension methods for type-safe navigation
extension AppRouteExtension on AppRoute {
  /// Get the route path
  String get location => path;

  /// Get the route name for GoRouter
  String get name => toString().split('.').last;
}