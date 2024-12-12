import 'package:flutter/material.dart';
import 'package:yummap/constant/theme.dart';

class RatingFilterModal extends StatefulWidget {
  final double initialMinRating;
  final double initialMaxRating;
  final Function(double, double) onApply;

  const RatingFilterModal({
    Key? key,
    required this.initialMinRating,
    required this.initialMaxRating,
    required this.onApply,
  }) : super(key: key);

  @override
  State<RatingFilterModal> createState() => _RatingFilterModalState();
}

class _RatingFilterModalState extends State<RatingFilterModal> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    _currentRangeValues = RangeValues(widget.initialMinRating, widget.initialMaxRating);
  }

  String _formatRating(double value) {
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Note',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'De ${_formatRating(_currentRangeValues.start)}',
                style: const TextStyle(fontSize: 16),
              ),
              const Text(' à ', style: TextStyle(fontSize: 16)),
              Text(
                _formatRating(_currentRangeValues.end),
                style: const TextStyle(fontSize: 16),
              ),
              const Text(' étoiles', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.orangeButton,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: AppColors.orangeButton,
              overlayColor: AppColors.orangeButton.withOpacity(0.2),
              valueIndicatorColor: AppColors.orangeButton,
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: RangeSlider(
              values: _currentRangeValues,
              min: 1.0,
              max: 5.0,
              divisions: 40, // Pour avoir une précision de 0.1
              labels: RangeLabels(
                _formatRating(_currentRangeValues.start),
                _formatRating(_currentRangeValues.end),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orangeButton,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              widget.onApply(_currentRangeValues.start, _currentRangeValues.end);
              Navigator.pop(context);
            },
            child: const Text(
              'Appliquer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
