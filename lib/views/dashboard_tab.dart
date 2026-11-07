import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/invoice_model.dart';
import '../models/room_model.dart';
import '../providers/auth_provider.dart';
import '../providers/rental_provider.dart';
import 'invoice_detail_dialog.dart';
import 'maintenance_screen.dart';
import 'settings_screen.dart';
import 'widgets/billing_bottom_sheet.dart';

/// ============================================================================
/// UI TAB: Màn Hình Tổng Quan Báo Cáo Thống Kê (DashboardTab)
/// ============================================================================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  void _openBillingBottomSheet(BuildContext context, Room room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BillingBottomSheet(room: room),
    );
  }

  void _showInvoiceDetail(BuildContext context, Invoice inv) {
    showDialog(
      context: context,
      builder: (ctx) => InvoiceDetailDialog(invoice: inv),
    );
  }

  void _showRoomListModal(
    BuildContext context, {
    required String title,
    required List<Room> rooms,
    required Color primaryColor,
    required String emptyMessage,
  }) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final loc = context.loc;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (ctx2, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx2).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag Indicator & Header
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: primaryColor.withValues(alpha: 0.15),
                          child: Icon(
                            primaryColor == Colors.green
                                ? Icons.meeting_room
                                : Icons.group,
                            color: primaryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '$title (${rooms.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Room list
              Expanded(
                child: rooms.isEmpty
                    ? Center(
                        child: Text(
                          emptyMessage,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: rooms.length,
                        itemBuilder: (context, index) {
                          final room = rooms[index];
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
                                      Text(
                                        room.name,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        currencyFormatter.format(room.basePrice),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3F51B5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (room.status == RoomStatus.occupied) ...[
                                    Row(
                                      children: [
                                        const Icon(Icons.person,
                                            size: 15, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('${loc.tenant}: ${room.tenantName ?? loc.unknownTenant}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500)),
                                        const Spacer(),
                                        if (room.phone != null &&
                                            room.phone!.isNotEmpty) ...[
                                          const Icon(Icons.phone,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(room.phone!,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade700)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.group,
                                            size: 15, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Text('${loc.occupantCount}: ${room.occupantCount} ${loc.people}',
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '📅 ${loc.checkIn}: ${room.checkInDate != null ? dateFormat.format(room.checkInDate!) : 'N/A'}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '🏁 ${loc.checkOut}: ${room.checkOutDate != null ? dateFormat.format(room.checkOutDate!) : 'N/A'}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _openBillingBottomSheet(context, room);
                                        },
                                        icon: const Icon(Icons.calculate, size: 16),
                                        label: Text(loc.billingAction),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      '${loc.initialElecLabel}: ${room.oldElectricity} kWh | ${loc.initialWaterLabel}: ${room.oldWater} m³',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        loc.roomStatus(room.status),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        shadowColor: const Color(0x14000000),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade400),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<RentalProvider>();
    final loc = context.loc;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    final availableRooms =
        provider.rooms.where((r) => r.status == RoomStatus.available).toList();
    final occupiedRooms =
        provider.rooms.where((r) => r.status == RoomStatus.occupied).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Welcome Greeting Card + Quick Settings Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: Color(0xFF3F51B5)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${loc.login.toLowerCase() == 'login' ? 'Hello' : loc.language == '语言设置' ? '您好' : 'Xin chào'}, ${auth.userName} 👋',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${loc.systemRole}: ${auth.userRole == 'Chủ trọ' ? loc.roleLandlord : auth.userRole} | ${auth.userEmail ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.build_circle_outlined, color: Colors.orange),
                  tooltip: 'Quản lý Bảo trì Sự cố',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MaintenanceScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF3F51B5)),
                  tooltip: loc.settingsTitle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Banner Doanh Thu Dự Kiến
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D3F51B5),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.expectedRevenue,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0x33FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  currencyFormatter.format(provider.totalExpectedRevenue),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.basedOnRentedRooms,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Unpaid Debt Card
          if (provider.totalUnpaidDebt > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.totalUnpaidDebt,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currencyFormatter.format(provider.totalUnpaidDebt),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        Text(
                          loc.unpaidInvoicesCount(provider.unpaidInvoicesCount),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Maintenance Alert Card (Sự cố bảo trì cần xử lý)
          if (provider.pendingMaintenanceCount > 0) ...[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MaintenanceScreen()),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: const Icon(Icons.build_outlined,
                          color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SỰ CỐ BẢO TRÌ CẦN XỬ LÝ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${provider.pendingMaintenanceCount} yêu cầu hỏng hóc chưa xong',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          Text(
                            'Bấm vào để xem danh sách & cập nhật chi phí sửa chữa',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF3F51B5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 3 Interactive Stat Cards Row
          Row(
            children: [
              _buildStatCard(
                context: context,
                title: loc.statAvailable,
                value: '${provider.availableCount}',
                icon: Icons.meeting_room_outlined,
                color: Colors.green,
                onTap: () {
                  _showRoomListModal(
                    context,
                    title: loc.modalAvailableRooms,
                    rooms: availableRooms,
                    primaryColor: Colors.green,
                    emptyMessage: loc.noEmptyRoomsMsg,
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                context: context,
                title: loc.statOccupied,
                value: '${provider.occupiedCount}',
                icon: Icons.people_outline,
                color: Colors.orange,
                onTap: () {
                  _showRoomListModal(
                    context,
                    title: loc.modalOccupiedRooms,
                    rooms: occupiedRooms,
                    primaryColor: Colors.orange.shade900,
                    emptyMessage: loc.noRentedRoomsMsg,
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                context: context,
                title: loc.statOccupancy,
                value: '${provider.occupancyRate.toStringAsFixed(0)}%',
                icon: Icons.pie_chart_outline,
                color: const Color(0xFF3F51B5),
                onTap: () {
                  _showRoomListModal(
                    context,
                    title: loc.modalOccupancyRooms,
                    rooms: provider.rooms,
                    primaryColor: const Color(0xFF3F51B5),
                    emptyMessage: loc.noRoomsData,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Chốt điện nước
          Text(
            loc.roomsNeedBilling,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5),
            ),
          ),
          const SizedBox(height: 10),
          if (occupiedRooms.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loc.noRentedRooms,
                style: const TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: occupiedRooms.length,
              itemBuilder: (context, index) {
                final room = occupiedRooms[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x1A3F51B5),
                      child: Icon(
                        Icons.meeting_room,
                        color: Color(0xFF3F51B5),
                      ),
                    ),
                    title: Text(
                      room.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${loc.tenant}: ${room.tenantName ?? loc.unknownTenant}\n${loc.oldIndex} (${loc.electricityCharge}): ${room.oldElectricity} kWh | ${loc.oldIndex} (${loc.waterCharge}): ${room.oldWater} m³',
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: () => _openBillingBottomSheet(context, room),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Text(loc.billingAction, style: const TextStyle(fontSize: 13)),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // Lịch sử hóa đơn gần đây
          if (provider.invoices.isNotEmpty) ...[
            Text(
              loc.recentInvoices,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.invoices.length,
              itemBuilder: (context, index) {
                final inv = provider.invoices[index];
                final formattedDate =
                    DateFormat('dd/MM/yyyy HH:mm').format(inv.createdAt);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          inv.isPaid ? Colors.green : Colors.orange.shade800,
                      child: Icon(
                        inv.isPaid ? Icons.check : Icons.access_time_filled,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      '${inv.roomName} - ${inv.tenantName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        '${loc.createdDate}: $formattedDate\n${loc.invoiceStatus(inv.status)}'),
                    isThreeLine: true,
                    trailing: Text(
                      currencyFormatter.format(inv.totalAmount),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: inv.isPaid ? Colors.green : Colors.orange.shade900,
                      ),
                    ),
                    onTap: () => _showInvoiceDetail(context, inv),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
