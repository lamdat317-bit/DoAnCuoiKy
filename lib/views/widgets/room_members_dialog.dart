import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/room_member_model.dart';
import '../../models/room_model.dart';
import '../../providers/rental_provider.dart';

/// ============================================================================
/// UI WIDGET: Hộp Thoại Quản Lý Danh Sách Thành Viên & CCCD (RoomMembersDialog)
/// ============================================================================
class RoomMembersDialog extends StatefulWidget {
  final Room room;

  const RoomMembersDialog({super.key, required this.room});

  @override
  State<RoomMembersDialog> createState() => _RoomMembersDialogState();
}

class _RoomMembersDialogState extends State<RoomMembersDialog> {
  bool _isLoading = true;
  List<RoomMember> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });
    final provider = context.read<RentalProvider>();
    final members = await provider.getRoomMembers(widget.room.id);
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  void _openAddEditMemberDialog({RoomMember? memberToEdit}) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditMemberSubDialog(
        roomId: widget.room.id,
        memberToEdit: memberToEdit,
        onSaved: () => _loadMembers(),
      ),
    );
  }

  void _confirmDeleteMember(RoomMember member) {
    final loc = context.loc;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            Text(loc.deleteMemberTitle),
          ],
        ),
        content: Text(
          loc.deleteMemberConfirmMsg(
            member.name,
            member.idCard,
            widget.room.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RentalProvider>().deleteRoomMember(
                member.id,
                widget.room.id,
              );
              await _loadMembers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.deleteMemberSuccess(member.name)),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              loc.deleteNow,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0x1A3F51B5),
                        child: Icon(Icons.badge, color: Color(0xFF3F51B5)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thành viên ${widget.room.name}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F51B5),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Danh sách đăng ký CCCD / CMND',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _members.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có thành viên nào được đăng ký CCCD',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Bấm nút bên dưới để thêm thành viên mới',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final m = _members[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: m.isRepresentative
                                  ? const Color(0xFF3F51B5)
                                  : Colors.transparent,
                              width: m.isRepresentative ? 1.5 : 0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: m.isRepresentative
                                          ? const Color(0xFF3F51B5)
                                          : Colors.grey.shade300,
                                      foregroundColor: m.isRepresentative
                                          ? Colors.white
                                          : Colors.black87,
                                      radius: 18,
                                      child: Text(
                                        m.name.isNotEmpty
                                            ? m.name[0].toUpperCase()
                                            : 'T',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Tên hiện đủ (xuống dòng nếu dài), nhãn "Đại diện" nằm dưới tên
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (m.isRepresentative) ...[
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0x1A3F51B5,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Đại diện hợp đồng',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF3F51B5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'CCCD/CMND: ${m.idCard}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                      ),
                                      onSelected: (val) {
                                        if (val == 'edit') {
                                          _openAddEditMemberDialog(
                                            memberToEdit: m,
                                          );
                                        } else if (val == 'delete') {
                                          _confirmDeleteMember(m);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                size: 18,
                                                color: Color(0xFF3F51B5),
                                              ),
                                              SizedBox(width: 8),
                                              Text('Chỉnh sửa'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                size: 18,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Xóa thành viên',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 4,
                                  children: [
                                    if (m.phone != null && m.phone!.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            m.phone!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (m.dateOfBirth != null)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.cake,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            dateFormat.format(m.dateOfBirth!),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (m.hometown != null &&
                                        m.hometown!.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.home_work,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Quê: ${m.hometown}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _openAddEditMemberDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'THÊM THÀNH VIÊN CCCD',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditMemberSubDialog extends StatefulWidget {
  final String roomId;
  final RoomMember? memberToEdit;
  final VoidCallback onSaved;

  const AddEditMemberSubDialog({
    super.key,
    required this.roomId,
    this.memberToEdit,
    required this.onSaved,
  });

  @override
  State<AddEditMemberSubDialog> createState() => _AddEditMemberSubDialogState();
}

class _AddEditMemberSubDialogState extends State<AddEditMemberSubDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idCardController;
  late TextEditingController _phoneController;
  late TextEditingController _hometownController;

  DateTime? _dateOfBirth;
  bool _isRepresentative = false;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final m = widget.memberToEdit;
    _nameController = TextEditingController(text: m?.name ?? '');
    _idCardController = TextEditingController(text: m?.idCard ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _hometownController = TextEditingController(text: m?.hometown ?? '');
    _dateOfBirth = m?.dateOfBirth;
    _isRepresentative = m?.isRepresentative ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    _phoneController.dispose();
    _hometownController.dispose();
    super.dispose();
  }

  Future<void> _selectDob(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      helpText: 'CHỌN NGÀY SINH',
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveMember() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final idCard = _idCardController.text.trim();
      final phone = _phoneController.text.trim();
      final hometown = _hometownController.text.trim();

      final isEditing = widget.memberToEdit != null;

      final member = RoomMember(
        id: isEditing
            ? widget.memberToEdit!.id
            : 'mem_${DateTime.now().millisecondsSinceEpoch}',
        roomId: widget.roomId,
        name: name,
        idCard: idCard,
        phone: phone.isNotEmpty ? phone : null,
        dateOfBirth: _dateOfBirth,
        hometown: hometown.isNotEmpty ? hometown : null,
        isRepresentative: _isRepresentative,
      );

      final provider = context.read<RentalProvider>();
      if (isEditing) {
        await provider.updateRoomMember(member);
      } else {
        await provider.addRoomMember(member);
      }

      widget.onSaved();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Cập nhật thông tin $name thành công!'
                  : 'Đã thêm $name vào danh sách CCCD thành công!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.memberToEdit != null;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing
                        ? 'Chỉnh sửa thông tin CCCD'
                        : 'Thêm thành viên CCCD',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  hintText: 'Nguyễn Văn A',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idCardController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số CCCD / CMND *',
                  hintText: '034099001234',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số CCCD hoặc CMND';
                  }
                  final clean = val.trim();
                  if (clean.length != 9 && clean.length != 12) {
                    return 'Số CCCD/CMND phải bao gồm 9 hoặc 12 chữ số';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: '0901234567',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDob(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cake,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ngày sinh',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _dateOfBirth != null
                                      ? _dateFormat.format(_dateOfBirth!)
                                      : 'Chọn ngày sinh',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hometownController,
                decoration: const InputDecoration(
                  labelText: 'Quê quán / Thường trú',
                  hintText: 'Hà Nội, Nam Định, ...',
                  prefixIcon: Icon(Icons.home_work),
                ),
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF3F51B5),
                title: const Text(
                  'Là người đại diện hợp đồng thuê phòng',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Tên và SĐT của người đại diện sẽ được đồng bộ lên thông tin phòng',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                value: _isRepresentative,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _isRepresentative = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _saveMember,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(
                  isEditing ? Icons.save : Icons.person_add,
                  color: Colors.white,
                ),
                label: Text(
                  isEditing ? 'CẬP NHẬT THÔNG TIN' : 'LƯU THÀNH VIÊN CCCD',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
