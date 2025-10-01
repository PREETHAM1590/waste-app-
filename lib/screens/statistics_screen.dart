import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waste_classifier_flutter/providers/theme_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        title: Text(
          'Progress Report',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildActivitySummary(context),
            const SizedBox(height: 32),
            _buildWasteBreakdown(context),
            const SizedBox(height: 32),
            _buildEcoPoints(context),
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummary(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              'Activity Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(context, '248', 'Items Scanned', AppColors.primary),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: _buildSummaryItem(context, '6', 'Categories', AppColors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 48,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWasteBreakdown(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Waste Breakdown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Donut Chart
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  children: [
                    PieChart(
                      PieChartData(
                        sections: _getChartSections(context),
                        centerSpaceRadius: 60,
                        sectionsSpace: 4,
                        startDegreeOffset: -90,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '248',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            'Total',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegend(context, AppColors.primary, 'Recyclable (40%)'),
                    const SizedBox(height: 8),
                    _buildLegend(context, AppColors.blue, 'Organic (35%)'),
                    const SizedBox(height: 8),
                    _buildLegend(context, AppColors.orange, 'E-Waste (15%)'),
                    const SizedBox(height: 8),
                    _buildLegend(context, AppColors.red, 'Hazardous (5%)'),
                    const SizedBox(height: 8),
                    _buildLegend(context, AppColors.textMuted, 'Other (5%)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getChartSections(BuildContext context) {
    return [
      PieChartSectionData(
        color: AppColors.primary,
        value: 40,
        title: '',
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        color: AppColors.blue,
        value: 35,
        title: '',
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        color: AppColors.orange,
        value: 15,
        title: '',
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        color: AppColors.red,
        value: 5,
        title: '',
        radius: 30,
        showTitle: false,
      ),
      PieChartSectionData(
        color: AppColors.textMuted,
        value: 5,
        title: '',
        radius: 30,
        showTitle: false,
      ),
    ];
  }

  Widget _buildLegend(BuildContext context, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEcoPoints(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Eco-Points',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'This Week',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Simple week indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayColumn(context, 'M', 5, false),
              _buildDayColumn(context, 'T', 6, false),
              _buildDayColumn(context, 'W', 8, false),
              _buildDayColumn(context, 'T', 12, true), // Today - highlighted
              _buildDayColumn(context, 'F', 0, false), // Future days
              _buildDayColumn(context, 'S', 0, false),
              _buildDayColumn(context, 'S', 0, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(BuildContext context, String day, int points, bool isToday) {
    final maxHeight = 60.0;
    final barHeight = points > 0 ? (points / 12) * maxHeight : 4.0; // Scale based on max 12 points
    
    return Column(
      children: [
        Container(
          height: maxHeight,
          width: 24,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 6,
            height: barHeight,
            decoration: BoxDecoration(
              color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isToday ? AppColors.primary : AppColors.textMuted,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
