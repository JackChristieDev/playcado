import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playcado/services/logger_service.dart';
import 'package:playcado/video_player/bloc/video_player_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is! PlayerPositionUpdated) {
      LoggerService.bloc.info('EVENT  [${bloc.runtimeType}] $event');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    LoggerService.bloc.severe(
      'ERROR  [${bloc.runtimeType}] $error',
      error,
      stackTrace,
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);

    // Skip logging for VideoPlayerBloc position-only updates to reduce noise
    if (bloc is VideoPlayerBloc &&
        change.currentState is VideoPlayerState &&
        change.nextState is VideoPlayerState) {
      if ((change.currentState as VideoPlayerState).isPositionOnlyChange(
        change.nextState as VideoPlayerState,
      )) {
        return;
      }
    }

    // Multi-line logging for easier diffing
    LoggerService.bloc.fine(
      'CHANGE [${bloc.runtimeType}]\n'
      '   Curr: ${change.currentState}\n'
      '   Next: ${change.nextState}',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    // Usually redundant if onChange is logged, but good for tracking Event->State flow
    // Keeping it concise as mostly duplication of onChange+onEvent
    // LoggerService.bloc.finer('TRANSITION [${bloc.runtimeType}] ${transition.event.runtimeType}');
  }
}
