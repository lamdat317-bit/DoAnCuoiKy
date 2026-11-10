import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/room_model.dart';
import '../../providers/rental_provider.dart';
import 'add_maintenance_dialog.dart';
import 'add_room_dialog.dart';
import 'billing_bottom_sheet.dart';
import 'checkout_dialog.dart';
import 'room_members_dialog.dart';

/// ============================================================================
/// UI WIDGET: Thẻ Hiển Thị Thông Tin Phòng Trọ (RoomCard)
/// ============================================================================
class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  Color _getStatusBackgroundColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green.shade100;
      case RoomStatus.occupied:
        return Colors.orange.shade100;
      case RoomStatus.maintenance:
        return Colors.grey.shade300;
    }
  }

  Color _getStatusTextColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green.shade900;
      case RoomStatus.occupied:
        return Colors.orange.shade900;
      case RoomStatus.maintenance:
        return Colors.grey.shade800;
    }
  }

  void _openBillingBottomSheet(BuildContext context) {
    if (context.read<RentalProvider>().hasInvoiceThisMonth(room.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.alreadyBilledThisMonth(room.name)),
          backgroundColor: Colors.orange.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BillingBottomSheet(room: room),
    );
  }

  void _openCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CheckoutDialog(room: room),
    );
  }

  void _openEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddRoomDialog(roomToEdit: room),
    );
  }

  void _openMembersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => RoomMembersDialog(room: room),
    );
  }

  void _openMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AddMaintenanceDialog(preselectedRoom: room),
    );
  }

  Future<void> _quickChangeCheckOutDate(BuildContext context) async {
    final loc = context.loc;
    final initialDate = room.checkOutDate ?? DateTime.now().add(const Duration(days: 180));
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2030);

    DateTime safeInitialDate = initialDate;
    if (safeInitialDate.isBefore(firstDate)) {
      safeInitialDate = firstDate;
    } else if (safeInitialDate.isAfter(lastDate)) {
      safeInitialDate = lastDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: '${loc.changeCheckoutDate.toUpperCase()} - ${room.name.toUpperCase()}',
      confirmText: loc.save.toUpperCase(),
      cancelText: loc.cancel.toUpperCase(),
    );

    if (picked != null && context.mounted) {
      final updatedRoom = room.copyWith(checkOutDate: picked);
      context.read<RentalProvider>().updateRoom(updatedRoom);

      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.checkoutDateUpdated} ($formattedDate)'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    final loc = context.loc;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: Colors.red),
            const SizedBox(width: 8),
            Text(loc.deleteRoomConfirmTitle),
          ],
        ),
        content: Text(loc.deleteRoomConfirmMsg(room.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<RentalProvider>().deleteRoom(room.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.deleteRoomSuccess(room.name)),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(loc.deleteNow, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(BuildContext context) {
    final loc = context.loc;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${loc.changeStatus} - ${room.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: RoomStatus.values.map((status) {
            return ListTile(
              title: Text(loc.roomStatus(status)),
              trailing: room.status == status
                  ? const Icon(Icons.check, color: Color(0xFF3F51B5))
                  : null,
              onTap: () {
                context.read<RentalProvider>().updateRoomStatus(room.id, status);
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoomImage(BuildContext context) {
    final loc = context.loc;
    if (room.imageUrl == null || room.imageUrl!.isEmpty) {
      return InkWell(
        onTap: () => _openEditDialog(context),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 6),
              Text(
                loc.addRoomImage,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final isNetwork = room.imageUrl!.startsWith('http://') ||
        room.imageUrl!.startsWith('https://');

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: isNetwork
          ? Image.network(
              room.imageUrl!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 120,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
                ),
              ),
            )
          : Image.file(
              File(room.imageUrl!),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                height: 120,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Ảnh phòng trọ
          _buildRoomImage(context),

          // Nội dung chi tiết phòng trọ
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng 1: Tên phòng, Badge trạng thái & Popup Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.meeting_room,
                            color: Color(0xFF3F51B5), size: 22),
                        const SizedBox(width: 8),
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showChangeStatusDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusBackgroundColor(room.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  loc.roomStatus(room.status),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusTextColor(room.status),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 16,
                                  color: _getStatusTextColor(room.status),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          tooltip: loc.edit,
                          onSelected: (value) {
                            if (value == 'members') {
                              _openMembersDialog(context);
                            } else if (value == 'maintenance') {
                              _openMaintenanceDialog(context);
                            } else if (value == 'edit') {
                              _openEditDialog(context);
                            } else if (value == 'checkout_dialog') {
                              _openCheckoutDialog(context);
                            } else if (value == 'checkout_date') {
                              _quickChangeCheckOutDate(context);
                            } else if (value == 'delete') {
                              _confirmDelete(context);
                            } else if (value == 'status') {
                              _showChangeStatusDialog(context);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem<String>(
                              value: 'members',
                              child: Row(
                                children: [
                                  Icon(Icons.badge_outlined,
                                      size: 18, color: Color(0xFF3F51B5)),
                                  SizedBox(width: 10),
                                  Text('Thành viên & CCCD'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'maintenance',
                              child: Row(
                                children: [
                                  Icon(Icons.build_outlined,
                                      size: 18, color: Colors.orange),
                                  SizedBox(width: 10),
                                  Text('Báo sự cố bảo trì'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined,
                                      size: 18, color: Color(0xFF3F51B5)),
                                  const SizedBox(width: 10),
                                  Text(loc.editRoomInfo),
                                ],
                              ),
                            ),
                            if (room.status == RoomStatus.occupied) ...[
                              PopupMenuItem<String>(
                                value: 'checkout_dialog',
                                child: Row(
                                  children: [
                                    const Icon(Icons.exit_to_app,
                                        size: 18, color: Colors.red),
                                    const SizedBox(width: 10),
                                    Text(loc.checkoutAndDeposit),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'checkout_date',
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_busy,
                                        size: 18, color: Colors.orange),
                                    const SizedBox(width: 10),
                                    Text(loc.changeCheckoutDate),
                                  ],
                                ),
                              ),
                            ],
                            PopupMenuItem<String>(
                              value: 'status',
                              child: Row(
                                children: [
                                  const Icon(Icons.swap_horiz,
                                      size: 18, color: Colors.orange),
                                  const SizedBox(width: 10),
                                  Text(loc.changeStatus),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Text(loc.deleteRoom,
                                      style: const TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Rent price
                Row(
                  children: [
                    const Icon(Icons.sell_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${loc.pricePerMonth}: ${currencyFormatter.format(room.basePrice)} / ${loc.month}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3F51B5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Electricity and Water meters
                Row(
                  children: [
                    const Icon(Icons.flash_on, size: 16, color: Colors.amber),
                    Text(
                      ' ${room.oldElectricity} kWh',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.water_drop, size: 16, color: Colors.blue),
                    Text(
                      ' ${room.oldWater} m³',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                    ),
                  ],
                ),

                // Customer & Occupant Info if occupied
                if (room.status == RoomStatus.occupied) ...[
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Color(0xFF3F51B5)),
                      const SizedBox(width: 6),
                      Text(
                        '${loc.tenantRepresentative}: ${room.tenantName ?? loc.unknownTenant}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (room.phone != null && room.phone!.isNotEmpty) ...[
                        const Icon(Icons.phone, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          room.phone!,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.group, size: 16, color: Colors.orange),
                      const SizedBox(width: 6),
                      Text(
                        '${loc.occupantCount}: ${room.occupantCount} ${loc.people}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      if (room.depositAmount > 0) ...[
                        const Spacer(),
                        Text(
                          '${loc.deposit}: ${currencyFormatter.format(room.depositAmount)}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3F51B5),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 15, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              '${loc.checkIn}: ${room.checkInDate != null ? dateFormat.format(room.checkInDate!) : 'N/A'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _quickChangeCheckOutDate(context),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_busy, size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${loc.checkOut}: ${room.checkOutDate != null ? dateFormat.format(room.checkOutDate!) : loc.pickDate}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.edit, size: 12, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const Divider(height: 20),

                // Bottom Action Buttons Row (Tính tiền, Trả phòng, Thành viên, Báo sự cố, Sửa)
                Row(
                  children: [
                    if (room.status == RoomStatus.occupied) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openBillingBottomSheet(context),
                          icon: const Icon(Icons.calculate, size: 16),
                          label: Text(loc.billingAction, style: const TextStyle(fontSize: 11)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3F51B5),
                            side: const BorderSide(color: Color(0xFF3F51B5)),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    OutlinedButton.icon(
                      onPressed: () => _openMembersDialog(context),
                      icon: const Icon(Icons.badge_outlined, size: 16),
                      label: const Text('Thành viên', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal.shade800,
                        side: BorderSide(color: Colors.teal.shade800),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      onPressed: () => _openMaintenanceDialog(context),
                      icon: const Icon(Icons.build_outlined, size: 16),
                      label: const Text('Bảo trì', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade900,
                        side: BorderSide(color: Colors.orange.shade900),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
