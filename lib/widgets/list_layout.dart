import 'package:flutter/material.dart';

import '../theme.dart';

class ReadingColumn extends StatelessWidget {
  const ReadingColumn({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    ),
  );
}

class ListHeading extends StatelessWidget {
  const ListHeading({
    super.key,
    required this.count,
    required this.status,
    required this.icon,
    this.onRefresh,
  });
  final int count;
  final String status;
  final IconData icon;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 10, onRefresh == null ? 20 : 8, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '$count ${count == 1 ? 'post' : 'posts'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFE4EBE2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: forest),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: const TextStyle(
                    color: forest,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onRefresh != null)
          IconButton(
            tooltip: 'Refresh posts',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            color: muted,
          ),
      ],
    ),
  );
}

class ListMessage extends StatelessWidget {
  const ListMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFE4EDE6),
              child: Icon(icon, size: 32, color: forest),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.45, color: muted),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onPressed, child: Text(action)),
          ],
        ),
      ),
    ),
  );
}
