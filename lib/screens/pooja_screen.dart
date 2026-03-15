import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/pooja_model.dart';
import '../services/pooja_service.dart';
import 'pooja_detail_screen.dart';

class PoojaScreen extends StatefulWidget {
  const PoojaScreen({super.key});

  @override
  State<PoojaScreen> createState() => _PoojaScreenState();
}

class _PoojaScreenState extends State<PoojaScreen> {
  @override
  void initState() {
    super.initState();
    PoojaService.load();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: PoojaService.isLoading,
      builder: (context, loading, _) {
        if (loading && PoojaService.poojas.value.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return ValueListenableBuilder<List<PoojaModel>>(
          valueListenable: PoojaService.poojas,
          builder: (context, poojas, _) {
            if (poojas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_outlined,
                        size: 48, color: AppColors.grey500),
                    const SizedBox(height: 12),
                    const Text('Could not load poojas',
                        style: TextStyle(color: AppColors.grey700)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => PoojaService.load(force: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 16 * 2 - 10) / 2;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: poojas
                        .map((pooja) => SizedBox(
                              width: cardWidth,
                              child: _PoojaCard(pooja: pooja),
                            ))
                        .toList(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PoojaCard extends StatelessWidget {
  final PoojaModel pooja;

  const _PoojaCard({required this.pooja});

  @override
  Widget build(BuildContext context) {
    final color = pooja.color;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PoojaDetailScreen(pooja: pooja),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(pooja.icon, color: color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  pooja.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  pooja.description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey700,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    pooja.duration,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
