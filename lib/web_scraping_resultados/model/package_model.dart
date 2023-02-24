class PackageModel {
  String horario;
  String casa;
  String fora;
  String placar;
  String gols;

  PackageModel({
    required this.horario,
    required this.casa,
    required this.fora,
    required this.placar,
    required this.gols
  });

  factory PackageModel.fromMap(Map<String, dynamic> map){
    return PackageModel(
      horario: map['horario'] ?? '',
      casa: map['casa'] ?? '',
      fora: map['fora'] ?? '',
      placar: map['placar'] ?? '',
      gols: map['gols'] ?? '',
    );
  }

}