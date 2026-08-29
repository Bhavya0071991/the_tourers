import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/portrait_repository.dart';
import '../domain/entities/portrait_design.dart';

final portraitRepositoryProvider = Provider<PortraitRepository>((ref) {
  return PortraitRepository();
});

final portraitListProvider = FutureProvider.autoDispose.family<List<PortraitDesign>, String>((ref, category) async {
  final repository = ref.watch(portraitRepositoryProvider);
  return repository.getPortraitDesigns(category: category);
});

final portraitByIdProvider = FutureProvider.autoDispose.family<PortraitDesign?, String>((ref, id) async {
  final repository = ref.watch(portraitRepositoryProvider);
  return repository.getPortraitDesignById(id);
});

// State for selecting sizing and frame style in PortraitDetailsPage
class PortraitCustomizerState {
  final String selectedSize; // 'A4', 'A3', 'A2'
  final String selectedFrame; // 'Canvas', 'Posters', 'Black Frame'
  final String selectedRoom; // 'Living Room', 'Studio', 'Bedroom'

  const PortraitCustomizerState({
    required this.selectedSize,
    required this.selectedFrame,
    required this.selectedRoom,
  });

  PortraitCustomizerState copyWith({
    String? selectedSize,
    String? selectedFrame,
    String? selectedRoom,
  }) {
    return PortraitCustomizerState(
      selectedSize: selectedSize ?? this.selectedSize,
      selectedFrame: selectedFrame ?? this.selectedFrame,
      selectedRoom: selectedRoom ?? this.selectedRoom,
    );
  }
}

class PortraitCustomizerNotifier extends Notifier<PortraitCustomizerState> {
  @override
  PortraitCustomizerState build() {
    return const PortraitCustomizerState(
      selectedSize: 'A4',
      selectedFrame: 'Black Frame',
      selectedRoom: 'Living Room',
    );
  }

  void updateSize(String size) {
    state = state.copyWith(selectedSize: size);
  }

  void updateFrame(String frame) {
    state = state.copyWith(selectedFrame: frame);
  }

  void updateRoom(String room) {
    state = state.copyWith(selectedRoom: room);
  }
}

final portraitCustomizerProvider = NotifierProvider.autoDispose<
    PortraitCustomizerNotifier, PortraitCustomizerState>(
  PortraitCustomizerNotifier.new,
);
