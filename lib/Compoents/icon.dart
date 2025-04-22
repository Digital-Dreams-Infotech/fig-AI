import 'package:flutter/material.dart';

IconData getCategoryIcon(String categoryId) {
  switch (categoryId) {
    case '1':
      return Icons.school;
    case '2':
      return Icons.device_hub;
    case '3':
      return Icons.business;
    case '4':
      return Icons.attach_money;
    case '5':
      return Icons.local_hospital;
    case '6':
      return Icons.fastfood;
    case '7':
      return Icons.checkroom;
    case '8':
      return Icons.travel_explore;
    case '9':
      return Icons.music_note;
    case '10':
      return Icons.science;
    case '11':
      return Icons.games;
    case '12':
      return Icons.sports;
    default:
      return Icons.folder;
  }
}
