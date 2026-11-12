import 'package:equatable/equatable.dart';

/// Enquadramento da foto do atleta na arte, ajustado pelo usuário arrastando
/// e com pinça na prévia: [x]/[y] de −1 a 1 (o ponto da foto que fica à vista,
/// como um `Alignment`) e [zoom] de 1 a 3. Fica só no aparelho.
class ArtPhotoFraming extends Equatable {
  static const double minZoom = 1;
  static const double maxZoom = 3;

  final double x;
  final double y;
  final double zoom;

  const ArtPhotoFraming({this.x = 0, this.y = -1, this.zoom = 1});

  /// O corte padrão: o centro do alto da foto (onde costuma estar o rosto).
  static const ArtPhotoFraming centered = ArtPhotoFraming();

  bool get isCentered => this == centered;

  static double _clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);

  /// Desloca o ponto à vista em [dx]/[dy] (na mesma escala de −1 a 1).
  ArtPhotoFraming moved(double dx, double dy) =>
      ArtPhotoFraming(x: _clamp(x + dx, -1, 1), y: _clamp(y + dy, -1, 1), zoom: zoom);

  /// Multiplica o zoom por [factor], entre [minZoom] e [maxZoom].
  ArtPhotoFraming zoomed(double factor) =>
      ArtPhotoFraming(x: x, y: y, zoom: _clamp(zoom * factor, minZoom, maxZoom));

  @override
  List<Object?> get props => [x, y, zoom];
}
