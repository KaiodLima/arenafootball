import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Situação de um envio registrado pelas Cloud Functions.
enum PushLogStatus { sent, disabled, error }

/// Um envio do histórico (`notificacoes_envios`, gravado pelas functions).
class PushLogDTO extends Equatable {
  final String id;

  /// Chave da ação (`PushAction.key`).
  final String type;
  final String title;
  final String body;

  /// Tópico ou condition usada.
  final String target;
  final String region;
  final DateTime? date;
  final PushLogStatus status;
  final String error;

  const PushLogDTO({
    this.id = '',
    this.type = '',
    this.title = '',
    this.body = '',
    this.target = '',
    this.region = '',
    this.date,
    this.status = PushLogStatus.sent,
    this.error = '',
  });

  factory PushLogDTO.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final rawDate = data['data'];
    return PushLogDTO(
      id: doc.id,
      type: data['tipo']?.toString() ?? '',
      title: data['titulo']?.toString() ?? '',
      body: data['corpo']?.toString() ?? '',
      target: data['alvo']?.toString() ?? '',
      region: data['regiao']?.toString() ?? '',
      date: rawDate is Timestamp ? rawDate.toDate() : null,
      status: switch (data['status']?.toString()) {
        'desligado' => PushLogStatus.disabled,
        'erro' => PushLogStatus.error,
        _ => PushLogStatus.sent,
      },
      error: data['erro']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, type, title, body, target, region, date, status, error];
}
