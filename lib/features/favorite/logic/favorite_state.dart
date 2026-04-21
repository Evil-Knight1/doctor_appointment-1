abstract class FavoriteState {
  const FavoriteState();
}

class FavoriteInitial extends FavoriteState {
  const FavoriteInitial();
}

class FavoriteLoading extends FavoriteState {
  const FavoriteLoading();
}

class FavoriteLoaded extends FavoriteState {
  final List<dynamic> favoriteDoctors;

  const FavoriteLoaded(this.favoriteDoctors);
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);
}

class FavoritePermissionDenied extends FavoriteState {
  final String message;

  const FavoritePermissionDenied(this.message);
}
