import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:risutaku/feature/viewer/persistence_provider.dart';
import 'package:risutaku/feature/calendar/calendar_models.dart';

final calendarFilterProvider = NotifierProvider.autoDispose<CalendarFilterNotifier, CalendarFilter>(
  CalendarFilterNotifier.new,
);

class CalendarFilterNotifier extends Notifier<CalendarFilter> {
  @override
  CalendarFilter build() => ref.watch(persistenceProvider.select((s) => s.calendarFilter));

  @override
  set state(CalendarFilter newState) {
    ref.read(persistenceProvider.notifier).setCalendarFilter(newState);
  }
}
