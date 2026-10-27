import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Situação da recompressão (`status` do doc).
enum RecompressPhase {
  idle(''),
  requested('pedido'),
  running('rodando'),
  done('concluido'),
  error('erro');

  final String key;

  const RecompressPhase(this.key);

  static RecompressPhase fromKey(String? key) {
    for (final phase in values) {
      if (phase.key == key) return phase;
    }
    return idle;
  }
}

/// `manutencao/recomprimir`: progresso da recompressão das imagens antigas
/// do Storage, gravado pela function `onRecompressRequested` a cada lote.
class RecompressStatusDTO extends Equatable {
  final RecompressPhase phase;

  /// Pasta do Storage em andamento (vazia ao concluir).
  final String folder;
  final int seen;
  final int rewritten;
  final int bytesBefore;
  final int bytesAfter;
  final String error;
  final DateTime? updatedAt;

  const RecompressStatusDTO({
    this.phase = RecompressPhase.idle,
    this.folder = '',
    this.seen = 0,
    this.rewritten = 0,
    this.bytesBefore = 0,
    this.bytesAfter = 0,
    this.error = '',
    this.updatedAt,
  });

  bool get isRunning => phase == RecompressPhase.requested || phase == RecompressPhase.running;

  /// Bytes economizados nas imagens regravadas.
  int get savedBytes => bytesBefore > bytesAfter ? bytesBefore - bytesAfter : 0;

  factory RecompressStatusDTO.fromMap(Map<String, dynamic> data) {
    int number(String key) => (data[key] as num?)?.toInt() ?? 0;
    return RecompressStatusDTO(
      phase: RecompressPhase.fromKey(data['status']?.toString()),
      folder: data['pasta']?.toString() ?? '',
      seen: number('vistos'),
      rewritten: number('regravados'),
      bytesBefore: number('bytesAntes'),
      bytesAfter: number('bytesDepois'),
      error: data['erro']?.toString() ?? '',
      updatedAt: (data['atualizadoEm'] as Timestamp?)?.toDate(),
    );
  }

  @override
  List<Object?> get props => [phase, folder, seen, rewritten, bytesBefore, bytesAfter, error, updatedAt];
}
