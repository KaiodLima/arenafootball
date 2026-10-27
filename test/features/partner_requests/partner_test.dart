import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_highlights_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_form_state.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/get_partner_slots_usecase.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_request_cubit.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_state.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

const _partner = PartnerRequestDTO(
  userId: 'p1',
  name: 'Rádio Floresta',
  region: 'Floresta',
  status: PlayerRequestStatus.approved,
);

class _NewsRepository implements INewsRepository {
  NewsDTO? created;

  @override
  Future<Either<Failure, void>> createNews(NewsDTO news) async {
    created = news;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Storage implements StorageUploadService {
  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async =>
      Right('https://storage/${file.path}');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Highlights implements WatchHighlightsUseCase {
  @override
  Stream<Either<Failure, List<HighlightDTO>>> call() => Stream.value(const Right([]));
}

/// O parceiro não carrega a lista de regiões (fica na dele).
class _NoRegions implements GetRegionsUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => fail('parceiro não escolhe região');
}

class _Slots implements GetPartnerSlotsUseCase {
  final Set<String> takenAds;

  _Slots(this.takenAds);

  @override
  Future<Either<Failure, PartnerSlotUsage>> call(PartnerRequestDTO partner, {DateTime? now}) async => Right(
        PartnerSlotUsage(
          adIds: PartnerSlots.adIds(partner.userId, partner.permissions.adsPerDay, DateTime.utc(2026, 10, 26, 15)),
          takenAds: takenAds,
        ),
      );
}

void main() {
  group('permissões', () {
    test('sem os campos: padrão (tudo liberado, 2 destaques, 1 publicidade por dia)', () {
      const permissions = PartnerPermissions();
      expect(PartnerPermissions.fromMap(const {}), permissions);
      expect(permissions.highlightLimit, 2);
      expect(permissions.adsPerDay, 1);
    });

    test('lê, grava e limita a 0..9', () {
      final permissions = PartnerPermissions.fromMap(const {
        'podeNoticias': false,
        'podeDestaques': true,
        'podePublicidade': true,
        'limiteDestaques': 30,
        'limitePublicidadeDia': 0,
      });
      expect(permissions.canNews, isFalse);
      expect(permissions.highlightLimit, 9);
      expect(permissions.canAdsNow, isFalse);
      expect(permissions.canPublish, isTrue);
      expect(permissions.toMap()['limiteDestaques'], 9);
    });

    test('o pedido do usuário nunca leva as permissões', () {
      final map = _partner.toSubmitMap();
      expect(map['status'], 'pendente');
      expect(map.keys, isNot(contains('podeNoticias')));
      expect(map.keys, isNot(contains('limiteDestaques')));
    });
  });

  group('vagas', () {
    test('dia em Brasília: 2h UTC ainda é o dia anterior', () {
      expect(PartnerSlots.brasiliaDay(DateTime.utc(2026, 10, 27, 2)), '2026-10-26');
      expect(PartnerSlots.brasiliaDay(DateTime.utc(2026, 1, 5, 12)), '2026-1-5');
    });

    test('ids iguais aos das regras', () {
      expect(PartnerSlots.highlightIds('p1', 2), ['dest0_p1', 'dest1_p1']);
      expect(PartnerSlots.adId('p1', 0, DateTime.utc(2026, 10, 26, 15)), 'pub0_p1_2026-10-26');
    });

    test('primeira vaga livre e o uso', () {
      const usage = PartnerSlotUsage(
        highlightIds: ['dest0_p1', 'dest1_p1'],
        takenHighlights: {'dest0_p1', 'dest5_p1'},
        adIds: ['pub0_p1_2026-10-26'],
        takenAds: {'pub0_p1_2026-10-26'},
      );
      expect(usage.freeHighlight, 'dest1_p1');
      expect(usage.usedHighlights, 1);
      expect(usage.freeAd, isNull);
      expect(usage.usedAds, 1);
    });
  });

  test('carrossel: gerais + os da região escolhida', () {
    const highlights = [
      HighlightDTO(id: 'a', title: 'Geral'),
      HighlightDTO(id: 'b', title: 'Rádio', region: 'Floresta', authorId: 'p1'),
      HighlightDTO(id: 'c', title: 'Loja', region: 'Santo Inácio', authorId: 'p2'),
    ];
    expect(highlightsForRegion(highlights, 'Floresta').map((h) => h.id), ['a', 'b']);
  });

  test('parceiro mexe só no que publicou', () {
    const state = PartnerState(request: _partner);
    expect(state.owns('p1'), isTrue);
    expect(state.owns('p2'), isFalse);
    expect(state.owns(''), isFalse);
    expect(PartnerState(request: _partner.copyWith(status: PlayerRequestStatus.removed)).owns('p1'), isFalse);
  });

  test('notícia grava o autor; editar mantém o original', () {
    expect(const NewsDTO(title: 'X', authorId: 'p1').toMap()['idAutor'], 'p1');
    expect(const NewsDTO(title: 'X').toMap().containsKey('idAutor'), isFalse);
    const form = NewsFormData(original: NewsDTO(id: 'n1', authorId: 'p1'), title: 'Y', authorId: 'admin');
    expect(form.toNews().authorId, 'p1');
  });

  group('formulário no modo parceiro', () {
    NewsFormCubit cubitOf(_NewsRepository repository, _Slots slots) => NewsFormCubit(
          CreateNewsUseCase(repository, _Storage()),
          UpdateNewsUseCase(repository, _Storage()),
          _NoRegions(),
          _Highlights(),
          slots,
        );

    test('região travada na dele e o autor é ele', () async {
      final cubit = cubitOf(_NewsRepository(), _Slots(const {}));
      await cubit.load(initialRegion: 'Santo Inácio', authorId: 'p1', partner: _partner);
      expect(cubit.state.form.selectedRegion, 'Floresta');
      expect(cubit.state.form.regions, ['Floresta']);
      expect(cubit.state.form.regionLocked, isTrue);
      expect(cubit.state.form.toNews().authorId, 'p1');
      await cubit.close();
    });

    test('publicidade vai na vaga do dia', () async {
      final repository = _NewsRepository();
      final cubit = cubitOf(repository, _Slots(const {}));
      await cubit.load(initialRegion: 'Floresta', tag: NewsDTO.adTag, partner: _partner);
      cubit.setCover(File('banner.png'));
      await cubit.submit();
      expect(cubit.state, isA<SuccessNewsFormState>());
      expect(repository.created?.id, 'pub0_p1_2026-10-26');
      await cubit.close();
    });

    test('sem vaga: avisa o limite e não grava', () async {
      final repository = _NewsRepository();
      final cubit = cubitOf(repository, _Slots(const {'pub0_p1_2026-10-26'}));
      await cubit.load(initialRegion: 'Floresta', tag: NewsDTO.adTag, partner: _partner);
      cubit.setCover(File('banner.png'));
      await cubit.submit();
      expect((cubit.state as ErrorNewsFormState).limitReached, isTrue);
      expect(repository.created, isNull);
      await cubit.close();
    });
  });

  group('vínculo de destaques sem dono', () {
    test('vai no pedido só quando há algum', () {
      expect(_partner.toSubmitMap().containsKey('idsDestaquesVinculo'), isFalse);
      expect(_partner.copyWith(claimedHighlightIds: ['h1']).toSubmitMap()['idsDestaquesVinculo'], ['h1']);
    });

    test('marcar e desmarcar', () {
      expect(PartnerRequestCubit.toggled(const ['a'], 'b'), ['a', 'b']);
      expect(PartnerRequestCubit.toggled(const ['a', 'b'], 'a'), ['b']);
    });

    test('vagas livres na ordem e o limite sobe para caber', () {
      final plan = HighlightLinkPlan.of(
        userId: 'p1',
        currentLimit: 2,
        claimed: const ['h1', 'h2'],
        taken: const {'dest0_p1'},
      );
      expect(plan.slots, {'h1': 'dest1_p1', 'h2': 'dest2_p1'});
      expect(plan.highlightLimit, 3);
    });

    test('com vaga sobrando o limite não muda; sem vaga até 9, fica de fora', () {
      expect(
        HighlightLinkPlan.of(userId: 'p1', currentLimit: 2, claimed: const ['h1'], taken: const {}).highlightLimit,
        2,
      );
      final full = HighlightLinkPlan.of(
        userId: 'p1',
        currentLimit: 9,
        claimed: const ['h1'],
        taken: PartnerSlots.highlightIds('p1', 9).toSet(),
      );
      expect(full.slots, isEmpty);
      expect(full.highlightLimit, 9);
    });
  });

}
