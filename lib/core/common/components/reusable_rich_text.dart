import 'package:flutter/material.dart';

class ReusableRichText extends StatelessWidget {
  const ReusableRichText({
    super.key,
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title: ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextSpan(
            text: value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
