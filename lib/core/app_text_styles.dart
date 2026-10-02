import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.darkText,
  );

  static const TextStyle small = TextStyle(
    fontSize: 13,
    color: AppColors.lightText,
  );

  static const TextStyle button = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}