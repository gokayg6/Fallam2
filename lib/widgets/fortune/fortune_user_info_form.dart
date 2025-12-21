import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/user_provider.dart';
import '../../core/widgets/glassmorphism_components.dart';
import '../../providers/theme_provider.dart';
import 'liquid_glass_picker.dart';

class FortuneUserInfoForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic>? initialData;

  const FortuneUserInfoForm({
    Key? key,
    required this.onChanged,
    this.initialData,
  }) : super(key: key);

  @override
  State<FortuneUserInfoForm> createState() => _FortuneUserInfoFormState();
}

class _FortuneUserInfoFormState extends State<FortuneUserInfoForm>
    with SingleTickerProviderStateMixin {
  // Form Fields
  String? _topic1;
  String? _topic2;
  bool _isForSelf = true;
  final TextEditingController _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _relationshipStatus;
  String? _jobStatus;
  late AnimationController _toggleController;
  late Animation<double> _toggleAnimation;

  // Data Lists
  List<String> get _topics => AppStrings.fortuneTopics;
  List<String> get _relationshipStatuses => AppStrings.relationshipStatusOptions;
  List<String> get _jobStatuses => AppStrings.jobStatusOptions;

  @override
  void initState() {
    super.initState();
    
    _toggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );
    
    if (widget.initialData != null) {
      _topic1 = widget.initialData!['topic1'];
      _topic2 = widget.initialData!['topic2'];
      _isForSelf = widget.initialData!['isForSelf'] ?? true;
      _nameController.text = widget.initialData!['name'] ?? '';
      _birthDate = widget.initialData!['birthDate'];
      _relationshipStatus = widget.initialData!['relationshipStatus'];
      _jobStatus = widget.initialData!['jobStatus'];
    } else {
      _topic1 = AppStrings.fortuneTopics.first; 
      _topic2 = AppStrings.fortuneTopics.length > 3 ? AppStrings.fortuneTopics[3] : AppStrings.fortuneTopics.last;
    }
    
    if (_isForSelf) {
      _toggleController.value = 1.0;
    }
    
    if (widget.initialData == null && _isForSelf) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fillUserData();
      });
    }
    
    _nameController.addListener(_notifyChanges);
  }

  void _fillUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user != null) {
      setState(() {
        if (user.name.isNotEmpty) _nameController.text = user.name;
        if (user.birthDate != null) _birthDate = user.birthDate;
        if (user.relationshipStatus != null && _relationshipStatuses.contains(user.relationshipStatus)) {
          _relationshipStatus = user.relationshipStatus;
        }
        if (user.job != null && _jobStatuses.contains(user.job)) {
          _jobStatus = user.job;
        }
      });
      _notifyChanges();
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_notifyChanges);
    _nameController.dispose();
    _toggleController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    widget.onChanged({
      'topic1': _topic1,
      'topic2': _topic2,
      'isForSelf': _isForSelf,
      'name': _nameController.text,
      'birthDate': _birthDate,
      'relationshipStatus': _relationshipStatus,
      'jobStatus': _jobStatus,
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showLiquidGlassDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
      _notifyChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Topics
        _buildSectionLabel(AppStrings.fortuneTopicsTitle, Icons.auto_awesome),
        const SizedBox(height: 12),
        GlassCard(
          borderRadius: 16,
          child: Column(
            children: [
              _buildTopicRow(AppStrings.topic1Label, _topic1, Icons.star, _topics, (val) {
                setState(() => _topic1 = val);
                _notifyChanges();
              }),
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              _buildTopicRow(AppStrings.topic2Label, _topic2, Icons.star_border, _topics, (val) {
                setState(() => _topic2 = val);
                _notifyChanges();
              }),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 2. For Whom?
        _buildSectionLabel(AppStrings.forWhomTitle, Icons.person),
        const SizedBox(height: 12),
        _buildForWhomToggle(),
        const SizedBox(height: 24),

        // 3. Name
        _buildSectionLabel(AppStrings.nameTitle, Icons.badge),
        const SizedBox(height: 12),
        GlassContainer(
          borderRadius: 16,
          child: TextField(
            controller: _nameController,
            style: PremiumTextStyles.body.copyWith(color: Colors.white),
            cursorColor: AppColors.champagneGold,
            decoration: InputDecoration(
              hintText: AppStrings.nameHint,
              hintStyle: PremiumTextStyles.body.copyWith(color: Colors.white38),
              prefixIcon: Icon(Icons.person_outline, color: AppColors.champagneGold),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 4. Birth Date
        _buildSectionLabel(AppStrings.birthDateTitle, Icons.cake),
        const SizedBox(height: 12),
        _buildDatePicker(),
        const SizedBox(height: 24),

        // 5. Relationship Status
        _buildSectionLabel(AppStrings.relationshipStatusTitle, Icons.favorite),
        const SizedBox(height: 12),
        _buildPickerField(
          value: _relationshipStatus,
          items: _relationshipStatuses,
          hint: AppStrings.selectHint,
          icon: Icons.favorite_border,
          title: AppStrings.relationshipStatusTitle,
          onChanged: (val) {
            setState(() => _relationshipStatus = val);
            _notifyChanges();
          },
        ),
        const SizedBox(height: 24),

        // 6. Job Status
        _buildSectionLabel(AppStrings.jobStatusTitle, Icons.work),
        const SizedBox(height: 12),
         _buildPickerField(
          value: _jobStatus,
          items: _jobStatuses,
          hint: AppStrings.selectHint,
          icon: Icons.business_center,
          title: AppStrings.jobStatusTitle,
          onChanged: (val) {
            setState(() => _jobStatus = val);
            _notifyChanges();
          },
        ),
        
        // Extra bottom padding for scroll
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.champagneGoldGradient.createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: PremiumTextStyles.headline.copyWith(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTopicRow(String label, String? value, IconData icon, List<String> items, ValueChanged<String?> onChanged) {
    return GestureDetector(
      onTap: () async {
        final result = await showLiquidGlassPicker(
          context: context,
          items: items,
          initialValue: value,
          title: label,
        );
        if (result != null) onChanged(result);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.champagneGold.withOpacity(0.8), size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: PremiumTextStyles.body.copyWith(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              value ?? AppStrings.selectHint,
              style: PremiumTextStyles.body.copyWith(
                color: value != null ? AppColors.champagneGold : Colors.white38,
                fontWeight: value != null ? FontWeight.w600 : FontWeight.normal
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildForWhomToggle() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: SizedBox(
        height: 50,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _isForSelf ? 0 : MediaQuery.of(context).size.width / 2 - 20, 
              // Note: Exact layout depends on parent constraints.
              // Assuming this widget is used in full width.
              // For consistent "half width" highlight, we can use LayoutBuilder.
              // But for now keeping it simple as before, but corrected
              // The previous implementation relied on Flex, but AnimatedPositioned needs explicit rect.
              // Let's use logic:
              // Since we don't know width here easily without LayoutBuilder,
              // Let's use a cleaner approach with AnimatedAlign or similar.
              child: Container(),
            ),
             Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isForSelf = true);
                        _toggleController.forward();
                        _fillUserData();
                        _notifyChanges();
                      },
                      child: Container(
                        color: Colors.transparent, // Hit test
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                           decoration: BoxDecoration(
                              color: _isForSelf ? AppColors.champagneGold.withOpacity(0.2) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, color: _isForSelf ? AppColors.champagneGold : Colors.white54, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.forMyself, style: PremiumTextStyles.body.copyWith(
                                color: _isForSelf ? AppColors.champagneGold : Colors.white54,
                                fontWeight: _isForSelf ? FontWeight.bold : FontWeight.normal
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: Colors.white.withOpacity(0.1)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isForSelf = false);
                        _toggleController.reverse();
                        _notifyChanges();
                      },
                      child: Container(
                         color: Colors.transparent,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                           decoration: BoxDecoration(
                              color: !_isForSelf ? AppColors.champagneGold.withOpacity(0.2) : Colors.transparent,
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people, color: !_isForSelf ? AppColors.champagneGold : Colors.white54, size: 18),
                              const SizedBox(width: 8),
                              Text(AppStrings.forSomeoneElse, style: PremiumTextStyles.body.copyWith(
                                color: !_isForSelf ? AppColors.champagneGold : Colors.white54,
                                fontWeight: !_isForSelf ? FontWeight.bold : FontWeight.normal
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.champagneGold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _birthDate == null
                    ? 'Gün / Ay / Yıl'
                    : DateFormat('dd/MM/yyyy').format(_birthDate!),
                style: PremiumTextStyles.body.copyWith(
                  color: _birthDate == null ? Colors.white38 : Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String? value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required String title,
    required ValueChanged<String?> onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await showLiquidGlassPicker(
          context: context,
          items: items,
          initialValue: value,
          title: title,
        );
        if (result != null) onChanged(result);
      },
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.champagneGold, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? hint,
                style: PremiumTextStyles.body.copyWith(
                   color: value != null ? Colors.white : Colors.white38,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}
