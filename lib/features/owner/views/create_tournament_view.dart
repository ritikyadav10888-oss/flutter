import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:force_player_register_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:force_player_register_app/features/owner/viewmodels/tournament_viewmodel.dart';
import 'package:force_player_register_app/core/models/models.dart';
// import 'package:force_player_register_app/core/theme/app_theme.dart';
// import '../../../shared/widgets/aura_widgets.dart';

class CreateTournamentView extends StatefulWidget {
  const CreateTournamentView({super.key});

  @override
  State<CreateTournamentView> createState() => _CreateTournamentViewState();
}

class _CreateTournamentViewState extends State<CreateTournamentView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _prizePoolController = TextEditingController();
  final _playersPerTeamController = TextEditingController();
  final _maxTeamsController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _termsController = TextEditingController();

  // State
  String _selectedSport = 'Cricket';
  TournamentType _type = TournamentType.normal;
  EntryFormat _entryFormat = EntryFormat.solo;

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  DateTime _registrationDeadline = DateTime.now();
  DateTime _organizerAccessExpiry = DateTime.now().add(
    const Duration(days: 30),
  );

  bool _enableScoring = false;
  bool _allowTeamOverflow = false;
  bool _isSubmitting = false;

  final List<String> _rules = [
    '11 players per team.',
    '20 overs per side.',
    'Umpire decision is final.',
    'Standard ICC rules apply.',
  ];

  final List<String> _sportTypes = [
    'Cricket',
    'Football',
    'Kabaddi',
    'Badminton',
    'Volleyball',
    'Basketball',
    'Kho Kho',
    'Table Tennis',
    'Tennis',
    'Athletics',
    'Hockey',
    'Chess',
    'Carrom',
    'Boxing',
    'Wrestling',
    'Swimming',
    'Snooker',
    'Rugby',
    'Handball',
    'Squash',
    'Gymnastics',
    'Cycling',
    'Archery',
    'Shooting',
    'Polo',
    'Golf',
    'Pickleball',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    _playersPerTeamController.dispose();
    _maxTeamsController.dispose();
    _maxParticipantsController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C5EAB)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Tournament',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Area
              _buildBannerArea(),
              const SizedBox(height: 24),

              // Basic Information Section
              _buildSectionCard(
                title: 'Basic Information',
                icon: Icons.emoji_events_outlined,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Tournament Name',
                    icon: Icons.title,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSportDropdown(),
                  const SizedBox(height: 24),

                  _buildLabel('Tournament Type'),
                  _buildTypeSelector(),
                  const SizedBox(height: 16),

                  _buildLabel('Entry Format'),
                  _buildEntryFormatSelector(),
                  const SizedBox(height: 16),

                  if (_entryFormat == EntryFormat.team) ...[
                    _buildTextField(
                      controller: _playersPerTeamController,
                      hint: 'Players per Team',
                      icon: Icons.groups,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _maxTeamsController,
                      hint: 'Max Teams (Total Slots)',
                      icon: Icons.group_add,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_entryFormat == EntryFormat.solo ||
                      _entryFormat == EntryFormat.duo) ...[
                    _buildTextField(
                      controller: _maxParticipantsController,
                      hint: 'Max Participants',
                      icon: Icons.person_add,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],

                  _buildTextField(
                    controller: _descriptionController,
                    hint: 'Description',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rules Section
              _buildSectionCard(
                title: 'Rules',
                icon: Icons.gavel_outlined,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _rules.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${index + 1}. ${_rules[index]}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _termsController,
                    hint: 'Terms & Conditions Policy',
                    icon: Icons.assignment_outlined,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prizes & Fees
              _buildSectionCard(
                title: 'Prizes & Fees',
                icon: Icons.payments_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _entryFeeController,
                          hint: 'Entry Fee (₹)',
                          icon: Icons.payments,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _prizePoolController,
                          hint: 'Prize Pool (₹)',
                          icon: Icons.stars,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Schedule
              _buildSectionCard(
                title: 'Schedule',
                icon: Icons.calendar_today_outlined,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimePicker(
                          label: 'Start Date',
                          value: DateFormat('dd-MM-yyyy').format(_startDate),
                          icon: Icons.calendar_month,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimePicker(
                          label: 'Start Time',
                          value: _startTime.format(context),
                          icon: Icons.access_time,
                          onTap: () => _selectTime(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimePicker(
                          label: 'End Date',
                          value: DateFormat('dd-MM-yyyy').format(_endDate),
                          icon: Icons.calendar_today,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimePicker(
                          label: 'Registration Deadline',
                          value: DateFormat(
                            'dd-MM-yyyy',
                          ).format(_registrationDeadline),
                          icon: Icons.report_problem,
                          onTap: () => _selectDeadline(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDateTimePicker(
                    label: 'Organizer Access Expiry Date',
                    value: DateFormat(
                      'dd-MM-yyyy',
                    ).format(_organizerAccessExpiry),
                    footerText:
                        'Organizers can only manage the tournament until this date.',
                    icon: Icons.access_time_filled,
                    onTap: () => _selectExpiry(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Assign Organizer
              _buildSectionCard(
                title: 'Assign Organizer',
                icon: Icons.person_outline,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Scoring System',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5C5EAB),
                            ),
                          ),
                          Text(
                            'Allow assigned organizer to manage live scores.',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('No', style: TextStyle(fontSize: 12)),
                          Radio<bool>(
                            value: false,
                            groupValue: _enableScoring,
                            onChanged: (v) =>
                                setState(() => _enableScoring = v!),
                          ),
                          const Text('Yes', style: TextStyle(fontSize: 12)),
                          Radio<bool>(
                            value: true,
                            groupValue: _enableScoring,
                            onChanged: (v) =>
                                setState(() => _enableScoring = v!),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Select an Organizer...',
                    icon: Icons.person_search,
                    readOnly: true,
                    onTap: () {
                      // TODO: Show organizer selection
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Create & Assign Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B6DB8),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create & Assign',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerArea() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              size: 40,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Banner / Poster',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              'Max 5MB • Any Aspect Ratio',
              style: TextStyle(color: Colors.grey[400], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF5C5EAB), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey, size: 18),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF5C5EAB)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSportDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSport,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _sportTypes
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videogame_asset,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(s, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedSport = v!),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: TournamentType.values.map((t) {
        final isSelected = _type == t;
        String label = 'Normal';
        if (t == TournamentType.teamBased) label = 'Team Based';
        if (t == TournamentType.auctionBased) label = 'Auction Based';

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _type = t),
            child:
                Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEBEBFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF5C5EAB)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? const Color(0xFF5C5EAB)
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                    ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEntryFormatSelector() {
    return Row(
      children: EntryFormat.values.map((f) {
        final isSelected = _entryFormat == f;
        String label = 'Solo';
        if (f == EntryFormat.duo) label = 'Hybrid (Solo & Duo)';
        if (f == EntryFormat.team) label = 'Team';
        if (f == EntryFormat.auctionPoolSolo) label = 'Auction Pool Solo';

        // Filter based on Type
        if (_type == TournamentType.auctionBased &&
            f != EntryFormat.auctionPoolSolo)
          return const SizedBox.shrink();
        if (_type == TournamentType.teamBased && f != EntryFormat.team)
          return const SizedBox.shrink();
        if (_type == TournamentType.normal && f == EntryFormat.auctionPoolSolo)
          return const SizedBox.shrink();

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _entryFormat = f),
            child:
                Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEBEBFF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF5C5EAB)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? const Color(0xFF5C5EAB)
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                    ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateTimePicker({
    required String label,
    required String value,
    required IconData icon,
    String? footerText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: onTap,
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: const Color(0xFF5C5EAB)),
                    const SizedBox(width: 8),
                    Text(value, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (footerText != null) ...[
          const SizedBox(height: 4),
          Text(
            footerText,
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate))
            _endDate = _startDate.add(const Duration(days: 1));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationDeadline,
      firstDate: DateTime.now(),
      lastDate: _startDate,
    );
    if (picked != null) setState(() => _registrationDeadline = picked);
  }

  Future<void> _selectExpiry(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _organizerAccessExpiry,
      firstDate: _endDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _organizerAccessExpiry = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final ownerId = context.read<AuthViewModel>().user?.uid;
    if (ownerId == null) return;

    setState(() => _isSubmitting = true);

    final tournament = Tournament(
      id: '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      sportType: _selectedSport,
      type: _type,
      entryFormat: _entryFormat,
      entryFee: double.tryParse(_entryFeeController.text) ?? 0.0,
      prizePool: double.tryParse(_prizePoolController.text) ?? 0.0,
      rules: _rules,
      terms: _termsController.text.trim(),
      date: DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      ),
      endDate: _endDate,
      registrationDeadline: _registrationDeadline,
      organizerAccessExpiry: _organizerAccessExpiry,
      location: _locationController.text
          .trim(), // Assuming we might want a location field hidden or added back
      bannerUrl: '',
      organizerId: '', // TODO: Get from selection
      createdBy: ownerId,
      status: 'OPEN',
      enableScoring: _enableScoring,
      playersPerTeam: int.tryParse(_playersPerTeamController.text),
      maxTeams: int.tryParse(_maxTeamsController.text),
      maxParticipants: int.tryParse(_maxParticipantsController.text),
      allowTeamOverflow: _allowTeamOverflow,
    );

    final success = await context.read<TournamentViewModel>().createTournament(
      tournament,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create tournament.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
