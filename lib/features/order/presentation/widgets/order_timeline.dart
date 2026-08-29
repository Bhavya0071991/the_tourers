import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';

class OrderTimeline extends StatelessWidget {
  final List<TrackingEvent> events;

  const OrderTimeline({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline indicator
              SizedBox(
                width: 32,
                child: Column(
                  children: [
                    // Dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: event.isCompleted
                            ? textColor
                            : Colors.transparent,
                        border: Border.all(
                          color: event.isCompleted
                              ? textColor
                              : textColor.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: event.isCompleted
                          ? Icon(
                              Icons.check,
                              size: 10,
                              color: surfaceColor,
                            )
                          : null,
                    ),
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: event.isCompleted
                              ? textColor
                              : textColor.withValues(alpha: 0.1),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: event.isCompleted
                              ? textColor
                              : textColor.withValues(alpha: 0.35),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.description,
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          color: event.isCompleted
                              ? textColor.withValues(alpha: 0.5)
                              : textColor.withValues(alpha: 0.25),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM, hh:mm a').format(event.timestamp),
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          color: event.isCompleted
                              ? textColor.withValues(alpha: 0.4)
                              : textColor.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
