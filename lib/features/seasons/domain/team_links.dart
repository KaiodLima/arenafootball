import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';

/// Coleções que a manutenção "Vincular times por id" completa.
enum TeamLinkTarget { players, matches, groups, championships, playerRequests, goalCards, users }

/// Campos de nome → campo de id de cada coleção.
abstract final class TeamLinkFields {
  static const players = {'time': 'idTime'};
  static const matches = {'timeC': 'idTimeC', 'timeF': 'idTimeF'};
  static const groups = {'time1': 'idTime1', 'time2': 'idTime2', 'time3': 'idTime3', 'time4': 'idTime4'};
  static const goalCards = {
    'time_casa': 'id_time_casa',
    'time_fora': 'id_time_fora',
    'time_marcador': 'id_time_marcador',
  };

  /// Usuário (time do coração), pedido "Sou jogador" e voto usam o mesmo par.
  static const playerRequests = players;
  static const users = players;
  static const votes = players;
}

/// Resultado da manutenção, para o relatório do admin.
class TeamLinkReport extends Equatable {
  /// Documentos atualizados por coleção (só as que tiveram alteração).
  final Map<TeamLinkTarget, int> updated;

  /// Votos copiados da coleção antiga para as partidas.
  final int votesCopied;

  /// Nomes que não batem com nenhum time da temporada.
  final List<String> unmatched;

  /// Nomes que existem em mais de um time (não dá para escolher pelo nome).
  final List<String> ambiguous;

  /// Confrontos cujos votos antigos não foram copiados (o mesmo par de times
  /// aparece em mais de uma partida da temporada).
  final List<String> skippedVotes;

  const TeamLinkReport({
    this.updated = const {},
    this.votesCopied = 0,
    this.unmatched = const [],
    this.ambiguous = const [],
    this.skippedVotes = const [],
  });

  int get totalUpdated => updated.values.fold(0, (sum, count) => sum + count);

  bool get isEmpty => totalUpdated == 0 && votesCopied == 0;

  @override
  List<Object?> get props => [updated, votesCopied, unmatched, ambiguous, skippedVotes];
}

/// Calcula, doc a doc, só os ids que faltam (o que já tem id não muda: rodar
/// de novo não altera nada) e guarda os nomes que não deu para resolver.
class TeamLinker {
  final TeamDirectory directory;
  final Set<String> _unmatched = {};
  final Set<String> _ambiguous = {};

  TeamLinker(this.directory);

  List<String> get unmatched => _unmatched.toList()..sort();

  List<String> get ambiguous => _ambiguous.toList()..sort();

  /// Id do time de nome [name]; '' (e anota o porquê) se não der.
  String _idOf(String name) {
    final team = directory.byName(name);
    if (team != null) return team.id;
    if (directory.ambiguousNames.contains(normalizeTeamName(name))) {
      _ambiguous.add(name.trim());
    } else {
      _unmatched.add(name.trim());
    }
    return '';
  }

  static String _text(Object? value) => value?.toString().trim() ?? '';

  /// Para cada par nome → id de [fields]: com nome e sem id, o id do time.
  Map<String, dynamic> missingIds(Map<String, dynamic> data, Map<String, String> fields) {
    final updates = <String, dynamic>{};
    fields.forEach((nameField, idField) {
      final name = _text(data[nameField]);
      if (name.isEmpty || _text(data[idField]).isNotEmpty) return;
      final id = _idOf(name);
      if (id.isNotEmpty) updates[idField] = id;
    });
    return updates;
  }

  /// `ids_times` do campeonato, alinhado com `times` ('' = não achou);
  /// mantém os ids que já existem.
  Map<String, dynamic> championshipIds(Map<String, dynamic> data) {
    final names = (data['times'] as List?)?.map(_text).toList() ?? const <String>[];
    final ids = (data['ids_times'] as List?)?.map(_text).toList() ?? const <String>[];
    if (names.isEmpty) return const {};
    final next = [
      for (var i = 0; i < names.length; i++)
        if (i < ids.length && ids[i].isNotEmpty) ids[i] else _idOf(names[i]),
    ];
    final changed =
        next.length != ids.length || [for (var i = 0; i < next.length; i++) next[i] != ids[i]].any((d) => d);
    return changed ? {'ids_times': next} : const {};
  }
}
