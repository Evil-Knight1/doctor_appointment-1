abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<String> banners;
  final List<String> categories;

  const HomeLoaded({required this.banners, required this.categories});
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);
}
