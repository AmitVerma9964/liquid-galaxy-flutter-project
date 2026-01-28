import 'package:flutter/material.dart';
import 'package:amti_fluttter_task1/models/filter.dart';
import 'package:amti_fluttter_task1/models/sol_day.dart';
import 'package:amti_fluttter_task1/utils/constants.dart';

/// A screen to demonstrate Filter functionality
class FilterDemoScreen extends StatefulWidget {
  const FilterDemoScreen({Key? key}) : super(key: key);

  @override
  State<FilterDemoScreen> createState() => _FilterDemoScreenState();
}

class _FilterDemoScreenState extends State<FilterDemoScreen> {
  Filter? _currentFilter;
  bool _isLoading = false;
  String _statusMessage = 'Load filter to begin';

  // Sample Sol days for testing
  final List<SolDay> _sampleDays = [
    SolDay(
      sol: 1,
      earthDate: DateTime(2012, 8, 6),
      totalPhotos: 10,
      cameras: ['FHAZ', 'RHAZ'],
    ),
    SolDay(
      sol: 100,
      earthDate: DateTime(2012, 11, 14),
      totalPhotos: 50,
      cameras: ['MAST', 'NAVCAM'],
    ),
    SolDay(
      sol: 500,
      earthDate: DateTime(2014, 1, 7),
      totalPhotos: 150,
      cameras: ['CHEMCAM', 'MAHLI'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFilter();
  }

  Future<void> _loadFilter() async {
    setState(() => _isLoading = true);

    try {
      final filter = await Filter.loadFilter(200, DateTime.now());
      setState(() {
        _currentFilter = filter;
        _statusMessage = 'Filter loaded successfully';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading filter: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFilter() async {
    if (_currentFilter == null) return;

    setState(() => _isLoading = true);

    try {
      await Filter.storeFilter(
        _currentFilter!.rangePhotosValuesStart,
        _currentFilter!.rangePhotosValuesEnd,
        _currentFilter!.startDate,
        _currentFilter!.endDate,
        _currentFilter!.camerasSelected,
      );

      setState(() {
        _statusMessage = 'Filter saved successfully';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter settings saved!')),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving filter: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _resetFilter() async {
    if (_currentFilter == null) return;

    setState(() => _isLoading = true);

    try {
      await Filter.resetFilter(_currentFilter!);
      await _loadFilter();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Filter reset to defaults!')),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error resetting filter: $e';
        _isLoading = false;
      });
    }
  }

  void _testFilterWithSampleDays() {
    if (_currentFilter == null) return;

    List<SolDay> validDays = _sampleDays.where((day) => _currentFilter!.isValidDay(day)).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Test Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total sample days: ${_sampleDays.length}'),
            Text('Valid days after filter: ${validDays.length}'),
            const SizedBox(height: 10),
            const Text('Valid days:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...validDays.map((day) => Text('Sol ${day.sol}: ${day.totalPhotos} photos')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Demo'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            _currentFilter != null ? Icons.check_circle : Icons.error,
                            color: _currentFilter != null ? Colors.green : Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _statusMessage,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Information
                  if (_currentFilter != null) ...[
                    const Text(
                      'Current Filter Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    _buildInfoCard(
                      'Photo Range',
                      '${_currentFilter!.rangePhotosValuesStart} - ${_currentFilter!.rangePhotosValuesEnd} photos',
                      Icons.photo_camera,
                    ),

                    _buildInfoCard(
                      'Date Range',
                      '${_formatDate(_currentFilter!.startDate)} to ${_formatDate(_currentFilter!.endDate)}',
                      Icons.date_range,
                    ),

                    _buildInfoCard(
                      'Selected Cameras',
                      '${_currentFilter!.camerasSelected.length} cameras: ${_currentFilter!.camerasSelected.join(", ")}',
                      Icons.camera_alt,
                    ),

                    const SizedBox(height: 20),

                    // Available Cameras
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Cameras:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            ...cameras.entries.map((entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _currentFilter!.camerasSelected.contains(entry.key)
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text('${entry.key}: ${entry.value}'),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons
                    const Text(
                      'Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _testFilterWithSampleDays,
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Test Filter with Sample Days'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _saveFilter,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Filter Settings'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _resetFilter,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset to Defaults'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton.icon(
                      onPressed: _loadFilter,
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Reload Filter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
