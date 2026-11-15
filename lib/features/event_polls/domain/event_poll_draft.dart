import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// O que falta no formulário do evento (a primeira encontrada).
enum EventPollDraftError { title, region, closesAt, tooFewOptions, optionTitle, optionLink }

/// Opção sendo editada: [photo] é a foto nova escolhida no aparelho (enviada
/// ao salvar); [imageUrl], a já salva.
class EventOptionDraft extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String link;
  final String imageUrl;
  final File? photo;

  const EventOptionDraft({
    required this.id,
    this.title = '',
    this.subtitle = '',
    this.link = '',
    this.imageUrl = '',
    this.photo,
  });

  /// Id curto e único no evento.
  static String newId() => 'o${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  factory EventOptionDraft.of(EventPollOption option) => EventOptionDraft(
        id: option.id,
        title: option.title,
        subtitle: option.subtitle,
        link: option.link,
        imageUrl: option.imageUrl,
      );

  EventPollOption toOption() =>
      EventPollOption(id: id, title: title.trim(), subtitle: subtitle.trim(), imageUrl: imageUrl, link: link.trim());

  EventOptionDraft copyWith({String? title, String? subtitle, String? link, File? photo, bool clearPhoto = false}) =>
      EventOptionDraft(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        link: link ?? this.link,
        imageUrl: clearPhoto ? '' : imageUrl,
        photo: clearPhoto ? null : photo ?? this.photo,
      );

  @override
  List<Object?> get props => [id, title, subtitle, link, imageUrl, photo?.path];
}

/// Formulário do evento de votação (admin).
class EventPollDraft extends Equatable {
  final String title;
  final String description;
  final String region;
  final DateTime? closesAt;
  final bool showPartial;
  final List<EventOptionDraft> options;

  const EventPollDraft({
    this.title = '',
    this.description = '',
    this.region = '',
    this.closesAt,
    this.showPartial = true,
    this.options = const [],
  });

  /// Novo: duas opções vazias e encerramento em 3 dias às 23:59.
  factory EventPollDraft.blank({required String region, required DateTime now}) {
    final day = now.add(const Duration(days: 3));
    return EventPollDraft(
      region: region,
      closesAt: DateTime(day.year, day.month, day.day, 23, 59),
      options: [
        EventOptionDraft(id: '${EventOptionDraft.newId()}a'),
        EventOptionDraft(id: '${EventOptionDraft.newId()}b'),
      ],
    );
  }

  factory EventPollDraft.of(NewsDTO news) {
    final event = news.event ?? const EventPoll();
    return EventPollDraft(
      title: news.title,
      description: news.description,
      region: news.region,
      closesAt: event.closesAt,
      showPartial: event.showPartial,
      options: [for (final option in event.options) EventOptionDraft.of(option)],
    );
  }

  /// Primeiro problema e, nos das opções, o índice dela.
  ({EventPollDraftError error, int option})? validate(DateTime now, {bool checkOptions = true}) {
    if (title.trim().isEmpty) return (error: EventPollDraftError.title, option: -1);
    if (region.trim().isEmpty) return (error: EventPollDraftError.region, option: -1);
    if (closesAt == null || !closesAt!.isAfter(now)) return (error: EventPollDraftError.closesAt, option: -1);
    if (!checkOptions) return null;
    if (options.length < EventPoll.minOptions) return (error: EventPollDraftError.tooFewOptions, option: -1);
    for (var i = 0; i < options.length; i++) {
      if (options[i].title.trim().isEmpty) return (error: EventPollDraftError.optionTitle, option: i);
      final link = options[i].link.trim();
      if (link.isNotEmpty && !SocialLink.isValid(link)) return (error: EventPollDraftError.optionLink, option: i);
    }
    return null;
  }

  /// Card do evento (notícia `tag: "evento"`): título/descrição legíveis no
  /// app antigo; [base] = o card em edição (id, data, capa e encerrado ficam).
  NewsDTO toNews({NewsDTO? base, String authorId = '', String imageUrl = ''}) {
    final previous = base?.event ?? const EventPoll();
    return (base ?? const NewsDTO()).copyWith(
      title: title.trim(),
      description: description.trim(),
      region: region,
      imageUrl: imageUrl,
      tag: NewsDTO.eventTag,
      isVisible: true,
      authorId: base == null ? authorId : null,
      event: EventPoll(
        options: [for (final option in options) option.toOption()],
        closesAt: closesAt,
        closed: previous.closed,
        showPartial: showPartial,
      ),
    );
  }

  /// Fotos novas das opções, por id.
  Map<String, File> get optionPhotos => {
        for (final option in options)
          if (option.photo != null) option.id: option.photo!,
      };

  EventPollDraft copyWith({
    String? title,
    String? description,
    String? region,
    DateTime? closesAt,
    bool? showPartial,
    List<EventOptionDraft>? options,
  }) =>
      EventPollDraft(
        title: title ?? this.title,
        description: description ?? this.description,
        region: region ?? this.region,
        closesAt: closesAt ?? this.closesAt,
        showPartial: showPartial ?? this.showPartial,
        options: options ?? this.options,
      );

  @override
  List<Object?> get props => [title, description, region, closesAt, showPartial, options];
}
