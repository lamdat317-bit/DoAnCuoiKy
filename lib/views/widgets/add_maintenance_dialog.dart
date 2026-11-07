import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final List<String> _sampleIssues = [
    'Hỏng máy lạnh / Không mát',
    'Nghẹt bồn rửa / Đường nước',
    'Hỏng bóng đèn / Điện chập',
    'Hỏng khóa cửa / Bản lề',
    'Thấm nước trần nhà / Tường',
    'Khác',
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
    if (_formKey.currentState!.validate()) {
      if (_selectedRoom == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn phòng phát sinh sự cố'),
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
                'Đã gửi báo cáo sự cố "${req.title}" cho ${_selectedRoom!.name} thành công!'),
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
                  const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0x1A3F51B5),
                        child: Icon(Icons.build, color: Color(0xFF3F51B5)),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Báo Sự Cố & Bảo Trì',
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
                decoration: const InputDecoration(
                  labelText: 'Chọn phòng xảy ra sự cố *',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                items: allRooms.map((room) {
                  return DropdownMenuItem<Room>(
                    value: room,
                    child: Text('${room.name} (${room.status.displayName})'),
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
                  if (val == null) return 'Vui lòng chọn phòng';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Gợi ý sự cố nhanh
              const Text(
                'Chọn mẫu sự cố nhanh:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _sampleIssues.map((issue) {
                  return ActionChip(
                    label: Text(issue, style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      setState(() {
                        _titleController.text = issue;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Nhập Tên sự cố
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên sự cố / Thiết bị hỏng *',
                  hintText: 'Ví dụ: Hỏng máy lạnh, Nghẹt nước',
                  prefixIcon: Icon(Icons.report_problem),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập tên sự cố';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Nhập Mô tả chi tiết
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết tình trạng',
                  hintText: 'Máy lạnh chảy nước, mở không lạnh...',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 12),

              // Nhập Chi phí dự kiến
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chi phí sửa chữa dự kiến (VNĐ)',
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
                label: const Text(
                  'GỬI BÁO CÁO SỰ CỐ',
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
