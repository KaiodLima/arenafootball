import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/domain/album_pack_id.dart';
import 'package:arena_soccer/features/album/domain/sticker_name.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/album/presentation/page/sticker_detail_page.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

class _AlbumUseCase implements AlbumUseCase {
  final event = StreamController<Either<Failure, AlbumEventDTO?>>.broadcast();
  final pack = StreamController<Either<Failure, AlbumPackDTO?>>.broadcast();

  @override
  Stream<Either<Failure, AlbumEventDTO?>> watchActiveEvent() => event.stream;

  @override
  Stream<Either<Failure, AlbumPackDTO?>> watchTodayPack({
    required String userId,
    required String eventId,
    DateTime? now,
  }) =>
      pack.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _event = AlbumEventDTO(id: 'ev1', title: 'Copa', active: true, teamIds: ['tB', 'tA'], teams: ['Beta', 'Alfa']);

const _stickers = [
  StickerDTO(id: 'a2', kind: StickerKind.athlete, name: 'Zé', teamId: 'tA', team: 'Alfa', order: 2),
  StickerDTO(id: 'a0', kind: StickerKind.crest, name: 'Alfa', teamId: 'tA', team: 'Alfa'),
  StickerDTO(id: 'a1', kind: StickerKind.athlete, name: 'Ana', teamId: 'tA', team: 'Alfa', order: 1),
  StickerDTO(id: 'b0', kind: StickerKind.crest, name: 'Beta', teamId: 'tB', team: 'Beta', number: 1),
];

void main() {
  test('páginas na ordem do evento, escudo primeiro e depois a ordem', () {
    final pages = AlbumLayout.pages(_event, _stickers);
    expect(pages.map((p) => p.teamId), ['tB', 'tA']);
    expect(pages[1].stickers.map((s) => s.id), ['a0', 'a1', 'a2']);
    expect(pages[1].team, 'Alfa');
  });

  test('numeração em sequência: devolve só as que mudaram', () {
    final changed = AlbumLayout.renumber(_event, _stickers);
    expect({for (final s in changed) s.id: s.number}, {'a0': 2, 'a1': 3, 'a2': 4});
  });

  test('gerar do elenco: escudo e só os atletas que faltam', () {
    final added = AlbumLayout.fromSquad(
      teamId: 'tA',
      team: 'Alfa',
      crestUrl: 'https://escudo',
      players: const [
        PlayerDTO(id: 'p1', name: 'Bia', team: 'Alfa', imageUrl: 'https://bia'),
        PlayerDTO(id: 'p2', name: 'Caio', team: 'Alfa'),
      ],
      existing: const [StickerDTO(id: 'x', teamId: 'tA', playerId: 'p2', order: 5)],
    );
    expect(added.map((s) => (s.kind, s.name, s.order)), [(StickerKind.crest, 'Alfa', 0), (StickerKind.athlete, 'Bia', 6)]);
    expect(added.last.imageUrl, 'https://bia');
  });

  test('álbum da conta: coladas, repetidas e página completa', () {
    final album = UserAlbumDTO.fromMap(const {'figurinhas': {'a0': 2, 'a1': 1, 'a2': 1, 'velha': 3}});
    expect(album.collected(_stickers), 3);
    expect(album.duplicates(_stickers), 1);
    final pages = AlbumLayout.pages(_event, _stickers);
    expect(pages[1].isComplete(album), isTrue);
    expect(pages[0].isComplete(album), isFalse);
  });

  test('id do pacote do dia igual ao das functions e das regras', () {
    expect(AlbumPackId.of(eventId: 'ev1', userId: 'u1', now: DateTime.utc(2026, 10, 28, 2)), 'ev1_u1_2026-10-27');
  });

  test('selo flutuante: evento ativo + conta; pacote disponível sem o doc de hoje', () async {
    final useCase = _AlbumUseCase();
    final cubit = AlbumEventCubit(useCase)..follow('u1');
    useCase.event.add(const Right(_event));
    await Future<void>.delayed(Duration.zero);
    useCase.pack.add(const Right(null));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.visible, isTrue);
    expect(cubit.state.packAvailable, isTrue);

    useCase.pack.add(const Right(AlbumPackDTO(id: 'p', status: AlbumPackStatus.opened)));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.packAvailable, isFalse);

    useCase.event.add(const Right(null));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.visible, isFalse);
    await cubit.close();
  });

  test('contagem do próximo pacote: até a meia-noite de Brasília', () {
    // 20h UTC = 17h em Brasília → faltam 7h.
    expect(AlbumPackId.untilNext(DateTime.utc(2026, 10, 28, 20)), const Duration(hours: 7));
    // 2h30 UTC = 23h30 do dia anterior em Brasília → 30 min.
    expect(AlbumPackId.untilNext(DateTime.utc(2026, 10, 28, 2, 30)), const Duration(minutes: 30));
  });

  test('detalhe: folheia só as coladas da página, na ordem', () {
    final album = UserAlbumDTO.fromMap(const {'figurinhas': {'a0': 1, 'a2': 2}});
    final page = AlbumLayout.pages(_event, _stickers)[1];
    final collected = page.collectedStickers(album);
    expect(collected.map((s) => s.id), ['a0', 'a2']);
    expect(collected.indexWhere((s) => s.id == 'a2'), 1);
  });

  test('texto de compartilhar a figurinha termina com o link do app', () {
    final l10n = lookupAppLocalizations(const Locale('pt'));
    const sticker = StickerDTO(id: 'a1', number: 12, name: 'Ana', team: 'Alfa');
    expect(stickerShareText(l10n, sticker, 'Copa'), 'Tirei a figurinha Nº 12 – Ana no álbum Copa!\n$appLink');
  });

  test('figurinha: primeiro nome pequeno e sobrenome em destaque', () {
    expect(StickerName.split('Carlos Eduardo Silva'), ('Carlos', 'Silva'));
    expect(StickerName.split('  Reginaldo '), ('', 'Reginaldo'));
    expect(StickerName.split(''), ('', ''));
  });

  test('figurinha: sigla de 3 letras do time', () {
    expect(StickerName.teamCode('Lava Jato FC'), 'LAV');
    expect(StickerName.teamCode('São Paulo'), 'SAO');
    expect(StickerName.teamCode('Esporte Clube Vila Nova Unida'), 'VNU');
    expect(StickerName.teamCode('Ás'), 'AS');
    expect(StickerName.teamCode(''), '');
  });

  test('evento em teste: selo só para o admin', () async {
    final useCase = _AlbumUseCase();
    final cubit = AlbumEventCubit(useCase)..follow('u1');
    useCase.event.add(Right(_event.copyWith().adminOnlyCopy()));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.visible, isFalse);

    cubit.follow('u1', isAdmin: true);
    expect(cubit.state.visible, isTrue);
    await cubit.close();
  });

  test('modo do evento: desligado, teste e para todos', () {
    expect(const AlbumEventDTO().mode, AlbumEventMode.off);
    expect(const AlbumEventDTO(active: true, adminOnly: true).mode, AlbumEventMode.test);
    expect(const AlbumEventDTO(active: true).mode, AlbumEventMode.all);
  });
}

extension on AlbumEventDTO {
  AlbumEventDTO adminOnlyCopy() => AlbumEventDTO(id: id, title: title, active: true, adminOnly: true, teamIds: teamIds);
}
