import 'package:flutter/material.dart';

class AddActivityScreen extends StatefulWidget {
  final String? activityId;
  final String? title;
  final String? description;
  final String? imagePath;
  final bool? isJoinable;
  final String? category;
  final String? score;
  final String? datetime;
  final String? location;

  const AddActivityScreen({
    super.key,
    this.activityId,
    this.title,
    this.description,
    this.imagePath,
    this.isJoinable,
    this.category,
    this.score,
    this.datetime,
    this.location,
  });

  @override
  _AddActivityScreenState createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();

  String _selectedDropdownValue = "ไม่มี";
  bool _isJoinable = true;

  // Validation messages
  String? _titleError;
  String? _descriptionError;
  String? _scoreError;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.title ?? '';
    _descriptionController.text = widget.description ?? '';
    _imageUrlController.text = widget.imagePath ?? '';
    _selectedDropdownValue = widget.category ?? "ไม่มี";
    _scoreController.text = widget.score ?? '';
    _locationController.text = widget.location ?? '';
    _isJoinable = widget.isJoinable ?? true;

    if (widget.datetime != null) {
      _selectedDateTime = DateTime.parse(widget.datetime!);
    }
  }

  void _saveActivity() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final score = _scoreController.text.trim();

    bool isValid = true;

    // Clear previous error messages
    setState(() {
      _titleError = null;
      _descriptionError = null;
      _scoreError = null;
    });

    // Validation
    if (title.isEmpty) {
      setState(() {
        _titleError = 'Title cannot be empty';
      });
      isValid = false;
    }

    if (description.isEmpty) {
      setState(() {
        _descriptionError = 'Description cannot be empty';
      });
      isValid = false;
    }

    if (_selectedDropdownValue != 'ไม่มี' && score.isEmpty) {
      setState(() {
        _scoreError = 'Score cannot be empty for the selected category';
      });
      isValid = false;
    }

    if (!isValid) return;

    final activityId = widget.activityId;
    final imageUrl = _imageUrlController.text.trim();
    final location = _locationController.text.trim();
    final datetime = _selectedDateTime.toIso8601String();

    final updatedActivity = {
      'activityId': activityId,
      'title': title,
      'description': description,
      'imagePath': imageUrl,
      'isJoinable': _isJoinable,
      'category': _selectedDropdownValue,
      'score': score,
      'datetime': datetime,
      'location': location,
    };

    Navigator.pop(context, updatedActivity);
  }

  Future<void> _selectDateTime() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null && selectedDate != _selectedDateTime) {
      final TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (selectedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Activity'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: _titleController,
                labelText: 'Title',
                errorText: _titleError,
              ),
              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: null,
                errorText: _descriptionError,
              ),
              _buildTextField(
                controller: _locationController,
                labelText: 'Location',
              ),
              _buildDateTimeButton(),
              _buildTextField(
                controller: _imageUrlController,
                labelText: 'Image URL',
              ),
              const SizedBox(height: 16.0),
              _buildDropdown(),
              if (_selectedDropdownValue != 'ไม่มี')
                _buildTextField(
                  controller: _scoreController,
                  labelText: 'Score',
                  keyboardType: TextInputType.number,
                  errorText: _scoreError,
                ),
              const SizedBox(height: 16.0),
              _buildJoinableSwitch(),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _saveActivity,
                child: const Text('Save Activity'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 210, 241, 238),
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    int? maxLines, // Add maxLines parameter
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines, // Set maxLines
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              errorText: errorText,
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                errorText,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ElevatedButton(
        onPressed: _selectDateTime,
        child: Text(
          'Select Date and Time: ${_selectedDateTime.toLocal().toString().substring(0, 16)}',
          style: const TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedDropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            _selectedDropdownValue = newValue!;
          });
        },
        items: <String>['ไม่มี', 'รู้วินัย', 'สภาวะผู้นำ', 'ใจอาสา', 'กตัญญู']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        ),
      ),
    );
  }

  Widget _buildJoinableSwitch() {
    return SwitchListTile(
      title: const Text('Joinable'),
      value: _isJoinable,
      onChanged: (bool value) {
        setState(() {
          _isJoinable = value;
        });
      },
    );
  }
}
