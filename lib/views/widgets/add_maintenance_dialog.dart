import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/maintenance_request_model.dart';
import '../../models/room_model.dart';
import '../../providers/rental_provider.dart';

/// ============================================================================
/// UI DIALOG: Hộp Thoại Báo Báo Sự Cố & Yêu Cầu Bảo Trì Thiết Bị (AddMaintenanceDialog)
/// ============================================================================
/// Cho phép chủ nhà hoặc khách thuê tạo yêu cầu sửa chữa hỏng hóc thiết bị trong phòng.
/// ============================================================================
class AddMaintenanceDialog extends StatefulWidget {
  final Room? preselectedRoom;

  const AddMaintenanceDialog({super.key, this.preselectedRoom});

  @override
  State<AddMaintenanceDialog> createState() => _AddMaintenanceDialogState();
}

class _AddMaintenanceDialogState extends State<AddMaintenanceDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _costController;

  Room? _selectedRoom;

  static const List<String> _sampleIssueKeys = [
    'issue_ac',
    'issue_sink',
    'issue_light',
    'issue_lock',
    'issue_leak',
    'issue_other',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.preselectedRoom;
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _costController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    final loc = context.loc;
    if (_formKey.currentState!.validate()) {
      if (_selectedRoom == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.t('maint_select_room_required')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final title = _titleController.text.trim();
      final desc = _descController.text.trim();
      final cost = double.tryParse(_costController.text.trim()) ?? 0.0;

      final req = MaintenanceRequest(
        id: 'maint_${DateTime.now().millisecondsSinceEpoch}',
        roomId: _selectedRoom!.id,
        roomName: _selectedRoom!.name,
        title: title,
        description: desc.isNotEmpty ? desc : null,
        repairCost: cost,
        status: MaintenanceStatus.pending,
        createdAt: DateTime.now(),
      );

      await context.read<RentalProvider>().addMaintenanceRequest(req);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                loc.t('maint_submitted', {'title': req.title, 'room': _selectedRoom!.name})),
            backgroundColor: Colors.orange.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final allRooms = provider.rooms;
    final loc = context.loc;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0x1A3F51B5),
                        child: Icon(Icons.build, color: Color(0xFF3F51B5)),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        loc.t('maint_dialog_title'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Dropdown Chọn Phòng trọ
              DropdownButtonFormField<Room>(
                initialValue: _selectedRoom,
                decoration: InputDecoration(
                  labelText: loc.t('maint_room_label'),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                items: allRooms.map((room) {
                  return DropdownMenuItem<Room>(
                    value: room,
                    child: Text('${room.name} (${loc.roomStatus(room.status)})'),
                  );
                }).toList(),
                onChanged: widget.preselectedRoom != null
                    ? null
                    : (val) {
                        setState(() {
                          _selectedRoom = val;
                        });
                      },
                validator: (val) {
                  if (val == null) return loc.t('maint_select_room');
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Gợi ý sự cố nhanh
              Text(
                loc.t('maint_quick_samples'),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _sampleIssueKeys.map((key) {
                  final issue = loc.t(key);
                  return ActionChip(
                    label: Text(issue, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      setState(() {
                        _titleController.text = issue;
                      });
                    },
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Nhập Tên sự cố
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: loc.t('maint_title_label'),
                  hintText: loc.t('maint_title_hint'),
                  prefixIcon: Icon(Icons.report_problem),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return loc.t('maint_title_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Nhập Mô tả chi tiết
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: loc.t('maint_desc_label'),
                  hintText: loc.t('maint_desc_hint'),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 12),

              // Nhập Chi phí dự kiến
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.t('maint_est_cost_label'),
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 20),

              // Nút Gửi Báo Cáo
              ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: Text(
                  loc.t('maint_submit_btn'),
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
