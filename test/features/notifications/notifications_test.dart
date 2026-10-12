import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/push_service.dart';
import 'package:arena_soccer/core/utils/push_topics.dart';
import 'package:arena_soccer/features/notifications/data/dtos/push_log_dto.dart';
import 'package:arena_soccer/features/notifications/domain/push_action.dart';
import 'package:arena_soccer/features/notifications/domain/repositories/notifications_repository_interface.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/send_manual_push_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/set_push_action_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/watch_push_config_usecase.dart';
import 'package:arena_soccer/features/notifications/domain/usecases/watch_push_history_usecase.dart';
import 'package:arena_soccer/features/notifications/presentation/bloc/notifications_panel_cubit.dart';
import 'package:arena_soccer/features/notifications/presentation/bloc/notifications_panel_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

class _FakeTopics implements TopicClient {
  final log = <String>[];

  @override
  Future<void> subscribe(String topic) async => log.add('+$topic');

  @override
  Future<void> unsubscribe(String topic) async => log.add('-$topic');
}

class _FakeRepository implements INotificationsRepository {
  final saved = <String, bool>{};
  final notices = <String>[];
  bool fail = false;

  @override
  Stream<Either<Failure, Map<String, bool>>> watchConfig() => Stream.value(const Right({'gol': false}));

  @override
  Future<Either<Failure, void>> setActionEnabled({required String key, required bool enabled}) async {
    if (fail) return Left(ErrorWithMessage('erro'));
    saved[key] = enabled;
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<PushLogDTO>>> watchHistory() => Stream.value(const Right([
        PushLogDTO(id: 'a', type: 'gol', title: 'GOL!', status: PushLogStatus.sent),
      ]));

  @override
  Future<Either<Failure, void>> sendManual({required String title, required String body, required String region}) async {
    if (fail) return Left(ErrorWithMessage('erro'));
    notices.add('$title|$body|$region');
    return const Right(null);
  }
}

class _FakeRegions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta', 'Santo inacio']);
}

void main() {
  group('tópicos', () {
    test('slug igual ao das Cloud Functions', () {
      expect(topicSlug('Santo inácio'), 'santo_inacio');
      expect(topicSlug('X-9 Caiçara'), 'x_9_caicara');
      expect(topicSlug('  Só Mulekes! '), 'so_mulekes');
    });

    test('desejados: todos + região + time (se houver)', () {
      expect(desiredTopics(region: 'Floresta', favoriteTeam: 'Lava Jato'),
          {'todos', 'regiao_floresta', 'time_lava_jato'});
      expect(desiredTopics(region: 'Floresta', favoriteTeam: ''), {'todos', 'regiao_floresta'});
    });

    test('logado: tópico do usuário; admin: também o dos admins', () {
      expect(desiredTopics(region: 'Floresta', userId: 'AbC123'), {'todos', 'regiao_floresta', 'usuario_AbC123'});
      expect(desiredTopics(region: 'Floresta', userId: 'AbC123', isAdmin: true),
          {'todos', 'regiao_floresta', 'usuario_AbC123', 'admins'});
    });

    test('trocar de região assina a nova e cancela a antiga', () async {
      SharedPreferences.setMockInitialValues({});
      final client = _FakeTopics();
      final sync = PushTopicSync(client);
      await sync.sync(desiredTopics(region: 'Floresta'));
      expect(client.log, unorderedEquals(['+todos', '+regiao_floresta']));

      client.log.clear();
      await sync.sync(desiredTopics(region: 'Santo inacio', favoriteTeam: 'Volta'));
      expect(client.log, unorderedEquals(['+regiao_santo_inacio', '+time_volta', '-regiao_floresta']));

      client.log.clear();
      await sync.sync(desiredTopics(region: 'Santo inacio', favoriteTeam: 'Volta'));
      expect(client.log, isEmpty);
    });
  });

  group('NotificationsPanelCubit', () {
    late _FakeRepository repository;
    late NotificationsPanelCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = NotificationsPanelCubit(
        WatchPushConfigUseCase(repository),
        SetPushActionUseCase(repository),
        WatchPushHistoryUseCase(repository),
        SendManualPushUseCase(repository),
        _FakeRegions(),
      );
      await cubit.load();
      await Future<void>.delayed(Duration.zero);
    });

    tearDown(() => cubit.close());

    test('config gravada vence o padrão; histórico e regiões carregados', () {
      expect(cubit.state.isEnabled(PushAction.goal), isFalse);
      expect(cubit.state.isEnabled(PushAction.news), isFalse);
      expect(cubit.state.isEnabled(PushAction.match), isTrue);
      expect(cubit.state.history.single.title, 'GOL!');
      expect(cubit.state.regions, ['Floresta', 'Santo inacio']);
    });

    test('liga/desliga grava; falha volta', () async {
      await cubit.toggle(PushAction.news, true);
      expect(repository.saved, {'noticia': true});
      expect(cubit.state.isEnabled(PushAction.news), isTrue);

      repository.fail = true;
      await cubit.toggle(PushAction.match, false);
      expect(cubit.state, isA<ErrorNotificationsPanelState>());
      expect(cubit.state.isEnabled(PushAction.match), isTrue);
    });

    test('aviso: exige título e texto; envia e limpa mantendo o destino', () async {
      await cubit.sendNotice();
      expect(repository.notices, isEmpty);

      cubit.changeNoticeTitle('  Rodada adiada ');
      cubit.changeNoticeBody('Chuva forte no campo.');
      cubit.changeNoticeRegion('Floresta');
      await cubit.sendNotice();
      expect(repository.notices, ['Rodada adiada|Chuva forte no campo.|Floresta']);
      expect(cubit.state, isA<NoticeSentNotificationsPanelState>());
      expect(cubit.state.notice, const ManualNoticeForm(region: 'Floresta'));
    });

    test('aviso longo demais não envia', () {
      final form = ManualNoticeForm(title: 'x' * (SendManualPushUseCase.titleMax + 1), body: 'ok');
      expect(form.canSend, isFalse);
    });
  });
}
