import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

void main() {
  const lavaJato = TeamDTO(id: 't1', name: 'Lava Jato');
  const volta = TeamDTO(id: 't2', name: 'Volta');
  const voltaOutraRegiao = TeamDTO(id: 't3', name: 'volta ');

  group('sameTeam', () {
    test('com id dos dois lados vale o id (mesmo com nomes diferentes)', () {
      expect(sameTeam(idA: 't1', nameA: 'Lava Jato', idB: 't1', nameB: 'Nome antigo'), isTrue);
      expect(sameTeam(idA: 't2', nameA: 'Volta', idB: 't3', nameB: 'Volta'), isFalse);
    });

    test('sem id em um dos lados (doc antigo): pelo nome normalizado', () {
      expect(sameTeam(idA: 't1', nameA: 'Lava Jato', nameB: ' lava jato'), isTrue);
      expect(sameTeam(nameA: 'Lava Jato', nameB: 'Volta'), isFalse);
      expect(sameTeam(), isFalse);
    });
  });

  group('TeamDirectory', () {
    test('resolve pelo id e, sem id, pelo nome', () {
      final directory = TeamDirectory(const [lavaJato, volta]);
      expect(directory.resolve(id: 't2', name: 'qualquer'), volta);
      expect(directory.resolve(name: 'LAVA JATO'), lavaJato);
      expect(directory.idOf(name: 'Volta'), 't2');
      expect(directory.idOf(id: 'x', name: 'Volta'), 'x');
      expect(directory.resolve(name: 'Inexistente'), isNull);
    });

    test('nome em dois times é ambíguo: não resolve pelo nome', () {
      final directory = TeamDirectory(const [volta, voltaOutraRegiao]);
      expect(directory.byName('Volta'), isNull);
      expect(directory.ambiguousNames, {'volta'});
      expect(directory.resolve(id: 't3', name: 'Volta'), voltaOutraRegiao);
    });
  });

  group('TeamLinker (migração)', () {
    test('preenche só os ids que faltam e anota os nomes sem time', () {
      final linker = TeamLinker(TeamDirectory(const [lavaJato, volta, voltaOutraRegiao]));

      expect(linker.missingIds({'timeC': 'Lava Jato', 'timeF': 'Riacho'}, TeamLinkFields.matches), {'idTimeC': 't1'});
      // Já tem id: não mexe (rodar de novo não altera nada).
      expect(linker.missingIds({'time': 'Lava Jato', 'idTime': 't1'}, TeamLinkFields.players), isEmpty);
      // Sem time: nada a fazer.
      expect(linker.missingIds({'time': ''}, TeamLinkFields.players), isEmpty);
      // Nome usado por dois times: não vincula.
      expect(linker.missingIds({'time': 'Volta'}, TeamLinkFields.players), isEmpty);

      expect(linker.unmatched, ['Riacho']);
      expect(linker.ambiguous, ['Volta']);
    });

    test('campeonato: ids alinhados com os nomes, mantendo os existentes', () {
      final linker = TeamLinker(TeamDirectory(const [lavaJato, volta]));
      expect(
        linker.championshipIds({
          'times': ['Lava Jato', 'Volta', 'Riacho'],
        }),
        {
          'ids_times': ['t1', 't2', ''],
        },
      );
      // Segunda execução com o resultado gravado: nada muda.
      expect(
        linker.championshipIds({
          'times': ['Lava Jato', 'Volta', 'Riacho'],
          'ids_times': ['t1', 't2', ''],
        }),
        isEmpty,
      );
    });

    test('relatório soma os documentos atualizados', () {
      const report = TeamLinkReport(updated: {TeamLinkTarget.players: 3, TeamLinkTarget.matches: 2}, votesCopied: 4);
      expect(report.totalUpdated, 5);
      expect(report.isEmpty, isFalse);
      expect(const TeamLinkReport().isEmpty, isTrue);
    });
  });
}
