import 'package:flutter/material.dart';

import '../../app/theme.dart';

class StatTile extends StatelessWidget {
  const StatTile(this.value, this.label, {super.key, this.light = false});
  final String value;
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: light ? Colors.white : AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
        ),
      ],
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.open});
  final bool open;

  @override
  Widget build(BuildContext context) {
    final color = open ? AppColors.success : AppColors.closed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        open ? 'OPEN' : 'CLOSED',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class PlaceImage extends StatelessWidget {
  const PlaceImage(this.url, {super.key, this.height = 140});
  final String? url;
  final double height;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFDCE9F5),
      child: const Icon(
        Icons.local_hospital,
        color: AppColors.primary,
        size: 40,
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Image.network(
      url!,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted),
      ),
    ),
  );
}

void showError(BuildContext context, Object e) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(e.toString())));
}
