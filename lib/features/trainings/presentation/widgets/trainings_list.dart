import 'package:flutter/material.dart';
import 'training_card.dart';

/// Lista de entrenamientos con scroll
class TrainingsList extends StatelessWidget {
  const TrainingsList({
    super.key,
    required this.trainings,
    required this.trainingTypes,
    required this.onTrainingTap,
    required this.onEdit,
    required this.onDelete,
    required this.onAttendance,
  });

  final List<Map<String, dynamic>> trainings;
  final Map<int, String> trainingTypes;
  final void Function(Map<String, dynamic>) onTrainingTap;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;
  final void Function(Map<String, dynamic>) onAttendance;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: trainings.length,
      itemBuilder: (context, index) {
        final training = trainings[index];
        final typeName = training['nombre']?.toString();

        return TrainingCard(
          training: training,
          typeName: typeName,
          onTap: () => onTrainingTap(training),
          onEdit: () => onEdit(training),
          onDelete: () => onDelete(training),
          onAttendance: () => onAttendance(training),
        );
      },
    );
  }
}
