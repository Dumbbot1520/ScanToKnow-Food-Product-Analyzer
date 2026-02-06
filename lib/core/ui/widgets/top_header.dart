// lib/core/ui/widgets/top_header.dart
import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final String avatarAsset;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSearchTap;

  const TopHeader({
    super.key,
    this.greeting = 'Hi User,',
    this.subtitle = 'Ready to discover healthier choices?',
    required this.avatarAsset,
    this.onAvatarTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + Avatar Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: Image.asset(
                      avatarAsset,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.person, size: 30),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Search Row (delegates behavior)
          _SearchRow(onTap: onSearchTap),
        ],
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final VoidCallback? onTap;
  const _SearchRow({this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: const Text(
                "Search for products, ingredients or brands",
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
