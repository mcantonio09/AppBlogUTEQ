import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {

  final String text;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),

        decoration: BoxDecoration(

          color: selected
              ? const Color.fromARGB(255, 32, 143, 234)
              : Colors.grey.shade200,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Text(

          text,

          style: TextStyle(

            color: selected
                ? Colors.white
                : const Color.fromARGB(221, 0, 0, 0),

            fontWeight:
                FontWeight.w500,
          ),
        ),
      ),
    );
  }
}