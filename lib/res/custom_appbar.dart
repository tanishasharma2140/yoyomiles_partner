import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String imageUrl;
  final List<Widget>? actions; // ✅ Add actions

  const CustomAppBar({
    super.key,
    required this.name,
    required this.imageUrl,
    this.actions, // Optional actions
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 5, // Shadow from bottom
      shadowColor: Colors.black.withOpacity(0.2),
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          const SizedBox(width: 12),

          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              imageUrl,
              height: 45,
              width: 45,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 45,
                width: 45,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name beside image
          Text(
            name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),

      // ✅ Right side actions
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
