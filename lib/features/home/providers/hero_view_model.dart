import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeroState {
  final int currentPage;

  const HeroState({this.currentPage = 0});

  HeroState copyWith({int? currentPage}) {
    return HeroState(currentPage: currentPage ?? this.currentPage);
  }
}

class HeroViewModel extends Notifier<HeroState> {
  Timer? _timer;
  static const int totalImages = 4; // Number of images in the carousel

  @override
  HeroState build() {
    _startTimer();

    ref.onDispose(() {
      _timer?.cancel();
    });

    return const HeroState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      nextPage();
    });
  }

  void nextPage() {
    final nextPageIndex = (state.currentPage + 1) % totalImages;
    setPage(nextPageIndex);
  }

  void setPage(int pageIndex) {
    if (state.currentPage != pageIndex) {
      state = state.copyWith(currentPage: pageIndex);
      // Restart timer on manual change to prevent immediate auto-slide
      _startTimer();
    }
  }
}

final heroViewModelProvider = NotifierProvider<HeroViewModel, HeroState>(
  HeroViewModel.new,
);
