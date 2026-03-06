import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:force_player_register_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:force_player_register_app/features/owner/viewmodels/tournament_viewmodel.dart';
import 'package:force_player_register_app/core/models/models.dart';
import 'package:force_player_register_app/core/theme/app_theme.dart';

class CreateTournamentView extends StatefulWidget {
  const CreateTournamentView({super.key});

  @override
  State<CreateTournamentView> createState() => _CreateTournamentViewState();
}

class _CreateTournamentViewState extends State<CreateTournamentView> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  final _rulesController = TextEditingController();
  final _contactController = TextEditingController();

  // State
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  String _status = 'OPEN';
  String _sportType = 'Football';
  String _format = '5v5';
  bool _isSubmitting = false;

  final List<String> _sportTypes = [
    'Football',
    'Cricket',
    'Basketball',
    'Badminton',
    'Volleyball',
    'Kabaddi',
    'Hockey',
    'Other',
  ];

  final List<String> _formats = [
    '1v1',
    '3v3',
    '5v5',
    '7v7',
    '11v11',
    'Individual',
    'Team',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _entryFeeController.dispose();
    _maxPlayersController.dispose();
    _rulesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Create Tournament'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          if (_currentStep == 2)
            TextButton.icon(
              onPressed: _isSubmitting ? null : _submitForm,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: AppTheme.primaryIndigo),
              label: Text(
                _isSubmitting ? 'Creating...' : 'Create',
                style: const TextStyle(
                  color: AppTheme.primaryIndigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Step Indicator ───────────────────────────────────────
            _buildStepIndicator(),
            // ── Step Content ─────────────────────────────────────────
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildBasicInfoStep(),
                  _buildDetailsStep(),
                  _buildRulesStep(),
                ],
              ),
            ),
            // ── Navigation Buttons ───────────────────────────────────
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  STEP INDICATOR
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepIndicator() {
    final steps = ['Basic Info', 'Details', 'Rules & Review'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? Colors.green
                            : isActive
                            ? AppTheme.primaryIndigo
                            : Colors.grey[200],
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.textMuted,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive
                            ? AppTheme.primaryIndigo
                            : AppTheme.textMuted,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: i < _currentStep ? Colors.green : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  STEP 1 — BASIC INFO
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Tournament Details', Icons.emoji_events),
          const SizedBox(height: 16),

          // Name
          _buildLabel('Tournament Name *'),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              'e.g. Summer Elite Cup 2026',
              Icons.sports_soccer,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 20),

          // Sport Type
          _buildLabel('Sport Type *'),
          DropdownButtonFormField<String>(
            value: _sportType,
            decoration: _inputDecoration('Select sport', Icons.sports),
            items: _sportTypes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _sportType = v!),
          ),
          const SizedBox(height: 20),

          // Format
          _buildLabel('Match Format'),
          DropdownButtonFormField<String>(
            value: _format,
            decoration: _inputDecoration('e.g. 5v5', Icons.group),
            items: _formats
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (v) => setState(() => _format = v!),
          ),
          const SizedBox(height: 20),

          // Location
          _buildLabel('Venue / Location *'),
          TextFormField(
            controller: _locationController,
            decoration: _inputDecoration(
              'e.g. City Stadium, Downtown',
              Icons.location_on_outlined,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Location is required' : null,
          ),
          const SizedBox(height: 20),

          // Date + Time Row
          _buildLabel('Date & Time *'),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: _inputDecoration('Date', Icons.calendar_today),
                    child: Text(DateFormat('dd MMM yyyy').format(_date)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: _inputDecoration('Time', Icons.access_time),
                    child: Text(_time.format(context)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  STEP 2 — EXTRA DETAILS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Additional Details', Icons.info_outline),
          const SizedBox(height: 16),

          // Description
          _buildLabel('Description'),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: _inputDecoration(
              'Describe the tournament, prizes, format details…',
              Icons.description_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Entry Fee + Max Players Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Entry Fee (₹)'),
                    TextFormField(
                      controller: _entryFeeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(
                        'e.g. 500',
                        Icons.currency_rupee,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Max Players'),
                    TextFormField(
                      controller: _maxPlayersController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration('e.g. 100', Icons.groups),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contact
          _buildLabel('Contact Number'),
          TextFormField(
            controller: _contactController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              'Organizer contact number',
              Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 20),

          // Status
          _buildLabel('Registration Status'),
          Row(
            children: ['OPEN', 'CLOSED'].map((s) {
              final isSelected = _status == s;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _status = s),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (s == 'OPEN' ? Colors.green : Colors.redAccent)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          s,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.textMuted,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  STEP 3 — RULES & REVIEW
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildRulesStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Rules & Review', Icons.rule),
          const SizedBox(height: 16),

          _buildLabel('Tournament Rules / Notes'),
          TextFormField(
            controller: _rulesController,
            maxLines: 5,
            decoration: _inputDecoration(
              'Add match rules, code of conduct, special notes…',
              Icons.notes,
            ),
          ),

          const SizedBox(height: 28),

          // ── Summary Preview Card ──
          _buildSectionHeader('Summary', Icons.preview),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _summaryRow(
                  Icons.emoji_events,
                  'Name',
                  _nameController.text.isEmpty ? '—' : _nameController.text,
                ),
                _summaryRow(Icons.sports, 'Sport', '$_sportType · $_format'),
                _summaryRow(
                  Icons.location_on_outlined,
                  'Venue',
                  _locationController.text.isEmpty
                      ? '—'
                      : _locationController.text,
                ),
                _summaryRow(
                  Icons.calendar_today,
                  'Date & Time',
                  '${DateFormat('dd MMM yyyy').format(_date)} at ${_time.format(context)}',
                ),
                _summaryRow(
                  Icons.currency_rupee,
                  'Entry Fee',
                  _entryFeeController.text.isEmpty
                      ? 'Free'
                      : '₹${_entryFeeController.text}',
                ),
                _summaryRow(
                  Icons.groups,
                  'Max Players',
                  _maxPlayersController.text.isEmpty
                      ? 'Unlimited'
                      : _maxPlayersController.text,
                ),
                _summaryRow(
                  Icons.circle,
                  'Status',
                  _status,
                  valueColor: _status == 'OPEN'
                      ? Colors.green
                      : Colors.redAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryIndigo),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppTheme.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  NAVIGATION BUTTONS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _currentStep--),
                icon: const Icon(Icons.arrow_back_ios, size: 16),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleNext,
              icon: _currentStep == 2
                  ? (_isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check))
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              label: Text(
                _currentStep == 2
                    ? (_isSubmitting ? 'Creating...' : 'Create Tournament')
                    : 'Next',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════════════════════════

  void _handleNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    } else {
      _submitForm();
    }
  }

  Future<void> _submitForm() async {
    final ownerId = context.read<AuthViewModel>().user?.uid;
    if (ownerId == null) return;

    setState(() => _isSubmitting = true);

    final tournament = Tournament(
      id: '',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      date: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      ),
      bannerUrl: '',
      organizerId: '',
      createdBy: ownerId,
      status: _status,
    );

    final success = await context.read<TournamentViewModel>().createTournament(
      tournament,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Tournament created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<TournamentViewModel>().errorMessage ??
                  'Failed to create tournament.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryIndigo, size: 20),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: AppTheme.primaryIndigo),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.primaryIndigo, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
