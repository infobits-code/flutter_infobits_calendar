import 'package:flutter/material.dart';
import '../extensions/date_time.dart';

import 'calendar_event.dart';
import 'calendar_event_modal_options.dart';
import 'calendar_style.dart';
import 'calendar_text.dart';

class CalendarEventModal<T extends CalendarEvent> extends StatelessWidget {
  final T event;
  final CalendarStyle<T> style;
  final CalendarEventStyle eventStyle;
  final CalendarText text;
  final CalendarEventModalOptions<T> options;
  final bool dialog;

  const CalendarEventModal({
    super.key,
    required this.event,
    this.dialog = false,
    required this.style,
    required this.eventStyle,
    required this.text,
    required this.options,
  });

  void onClosePressed(BuildContext context) async {
    if (options.onClosePressed != null) {
      var close = await options.onClosePressed!(event);
      if (close) Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  void onEditPressed(BuildContext context) async {
    if (options.onEditPressed != null) {
      var close = await options.onEditPressed!(event);
      if (close) Navigator.of(context).pop();
    }
  }

  void onDeletePressed(BuildContext context) async {
    if (options.onDeletePressed != null) {
      var close = await options.onDeletePressed!(event);
      if (close) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    var timePeriodString =
        "${event.startDate.toLocal().timeString}${event.endDate != null ? " - ${event.endDate!.toLocal().timeString}" : ""}";

    var fullPeriodString =
        "$timePeriodString, ${text.weekdays.weekday(event.startDate.toLocal())} ${event.startDate.toLocal().day}. ${text.months.month(event.startDate.toLocal())}";

    if (event.endDate != null && !event.startDate.isSameDate(event.endDate)) {
      var startDateString =
          "${event.startDate.toLocal().timeString} ${text.weekdays.weekday(event.startDate.toLocal())} ${event.startDate.toLocal().day}. ${text.months.month(event.startDate.toLocal())}";
      var endDateString =
          "${event.endDate!.toLocal().timeString} ${text.weekdays.weekday(event.endDate!.toLocal())} ${event.endDate!.toLocal().day}. ${text.months.month(event.endDate!.toLocal())}";
      fullPeriodString = "$startDateString - $endDateString";
    }

    List<Widget> modalChildren = [
      _buildModalRow(
        icon: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: eventStyle.backgroundColor,
              shape: BoxShape.circle,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              event.title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
            ),
            SelectableText(
              event.subtitle ?? "",
              style: const TextStyle(fontSize: 20),
            ),
            SelectableText(
              fullPeriodString,
              style: TextStyle(fontSize: 15, color: style.secondaryTextColor),
            )
          ],
        ),
      ),
    ];

    if (options.infoEntryBuilders.isNotEmpty) {
      for (var infoEntryBuilder in options.infoEntryBuilders) {
        var infoEntry = infoEntryBuilder(event, dialog);
        if (infoEntry == null) continue;
        modalChildren
            .add(_buildModalRow(icon: infoEntry.icon, child: infoEntry.child));
      }
    }

    if (options.extraContentBuilder != null) {
      var extraContent = options.extraContentBuilder!(event, dialog);
      if (extraContent != null) {
        modalChildren.add(extraContent);
      }
    }

    if (options.bottomActionBuilders.isNotEmpty) {
      List<Widget> actions = [];
      for (var actionBuilder in options.bottomActionBuilders) {
        var action = actionBuilder(event, dialog);
        if (action == null) continue;
        actions.add(action);
      }

      modalChildren.add(
        _buildModalRow(
          icon: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: style.icons.modalBottomActionsIcon,
          ),
          child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 5,
            runSpacing: 5,
            children: actions,
          ),
        ),
      );
    }

    if (dialog) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
                color: style.primaryBackgroundColor,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: modalChildren,
            ),
          ),
          Positioned(
              right: 10,
              top: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (options.onDeletePressed != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: GestureDetector(
                        onTap: () => onDeletePressed(context),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: style.secondaryBackgroundColor,
                            ),
                            child: style.icons.modalDeleteIcon,
                          ),
                        ),
                      ),
                    ),
                  if (options.onEditPressed != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: GestureDetector(
                        onTap: () => onEditPressed(context),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: style.secondaryBackgroundColor,
                            ),
                            child: style.icons.modalEditIcon,
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => onClosePressed(context),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: style.secondaryBackgroundColor,
                        ),
                        child: style.icons.modalCloseIcon,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      );
    }

    return Container(
        decoration: BoxDecoration(
            color: style.primaryBackgroundColor,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
              decoration: BoxDecoration(
                color: style.secondaryBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              margin: const EdgeInsets.fromLTRB(10, 15, 10, 20),
              width: 60,
              height: 5,
            )),
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: modalChildren,
              ),
            )),
          ],
        ));
  }

  Widget _buildModalRow({required Widget icon, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          width: 70,
          child: Center(child: icon),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
            child: child,
          ),
        )
      ],
    );
  }
}
