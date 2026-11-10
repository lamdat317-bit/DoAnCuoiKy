import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/maintenance_request_model.dart';
import '../providers/rental_provider.dart';
import 'widgets/add_maintenance_dialog.dart';

/// ============================================================================
/// UI SCREEN: Màn Hình Quản Lý Sự Cố & Bảo Trì Thiết Bị (MaintenanceScreen)
/// ============================================================================
/// Chức năng:
/// 1. Thống kê tổng số sự cố chờ xử lý và tổng chi phí sửa chữa.
/// 2. Lọc danh sách sự cố theo trạng thái (*Tất cả, Chờ xử lý, Đang sửa, Đã xong*).
/// 3. Cập nhật tiến độ xử lý và nhập chi phí sửa chữa.
/// 4. Tạo mới yêu cầu báo sự cố.
/// ============================================================================
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  MaintenanceStatus? _selectedFilter;

  void _openAddMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddMaintenanceDialog(),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, MaintenanceRequest req) {
    final costController =
        TextEditingController(text: req.repairCost.toStringAsFixed(0));
    MaintenanceStatus chosenStatus = req.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Cập nhật sự cố - ${req.roomName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tên sự cố: ${req.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<MaintenanceStatus>(
                initialValue: chosenStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái xử lý',
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items: MaintenanceStatus.values.map((status) {
                  return DropdownMenuItem<MaintenanceStatus>(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      chosenStatus = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chi phí sửa chữa (VNĐ)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
              ),
              onPressed: () async {
                final cost = double.tryParse(costController.text.trim()) ?? 0.0;
                await context.read<RentalProvider>().updateMaintenanceStatus(
                      req.id,
                      chosenStatus,
                      cost,
                    );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật sự cố ${req.title}'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Lưu thay đổi',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MaintenanceRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Xóa sự cố'),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa sự cố "${req.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<RentalProvider>().deleteMaintenanceRequest(req.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa báo cáo sự cố'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Xóa ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getStatusBgColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return Colors.orange.shade100;
      case MaintenanceStatus.inProgress:
        return Colors.blue.shade100;
      case MaintenanceStatus.completed:
        return Colors.green.shade100;
      case MaintenanceStatus.cancelled:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusTextColor(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return Colors.orange.shade900;
      case MaintenanceStatus.inProgress:
        return Colors.blue.shade900;
      case MaintenanceStatus.completed:
        return Colors.green.shade900;
      case MaintenanceStatus.cancelled:
        return Colors.grey.shade900;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final allRequests = provider.maintenanceRequests;

    final filteredRequests = allRequests.where((req) {
      if (_selectedFilter != null && req.status != _selectedFilter) {
        return false;
      }
      return true;
    }).toList();

    final currency =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sự cố & Bảo trì'),
      ),
      body: Column(
        children: [
          // Thẻ tóm tắt thông số bảo trì
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SỰ CỐ CẦN XỬ LÝ',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.pendingMaintenanceCount} yêu cầu',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TỔNG CHI PHÍ BẢO TRÌ',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currency.format(provider.totalMaintenanceCost),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips lọc theo trạng thái
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: Text('Tất cả (${allRequests.length})'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                      'Chờ xử lý (${allRequests.where((r) => r.status == MaintenanceStatus.pending).length})'),
                  selected: _selectedFilter == MaintenanceStatus.pending,
                  selectedColor: Colors.orange.shade100,
                  checkmarkColor: Colors.orange.shade900,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter =
                          selected ? MaintenanceStatus.pending : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                      'Đang sửa (${allRequests.where((r) => r.status == MaintenanceStatus.inProgress).length})'),
                  selected: _selectedFilter == MaintenanceStatus.inProgress,
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade900,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter =
                          selected ? MaintenanceStatus.inProgress : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(
                      'Đã xong (${allRequests.where((r) => r.status == MaintenanceStatus.completed).length})'),
                  selected: _selectedFilter == MaintenanceStatus.completed,
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green.shade900,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter =
                          selected ? MaintenanceStatus.completed : null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách sự cố bảo trì
          Expanded(
            child: filteredRequests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.build_circle_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có báo cáo sự cố nào',
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final req = filteredRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.meeting_room,
                                          size: 18, color: Color(0xFF3F51B5)),
                                      const SizedBox(width: 6),
                                      Text(
                                        req.roomName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _getStatusBgColor(req.status),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          req.status.displayName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _getStatusTextColor(req.status),
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert,
                                            size: 20),
                                        onSelected: (val) {
                                          if (val == 'update') {
                                            _showUpdateStatusDialog(context, req);
                                          } else if (val == 'delete') {
                                            _confirmDelete(context, req);
                                          }
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem<String>(
                                            value: 'update',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined,
                                                    size: 18,
                                                    color: Color(0xFF3F51B5)),
                                                SizedBox(width: 8),
                                                Text('Cập nhật tiến độ / Chi phí'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline,
                                                    size: 18,
                                                    color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Xóa báo cáo',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              Text(
                                req.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (req.description != null &&
                                  req.description!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  req.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                              const Divider(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Báo lúc: ${dateFormat.format(req.createdAt)}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  if (req.repairCost > 0)
                                    Text(
                                      'Chi phí: ${currency.format(req.repairCost)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF3F51B5),
                                      ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddMaintenanceDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Báo sự cố mới'),
      ),
    );
  }
}
