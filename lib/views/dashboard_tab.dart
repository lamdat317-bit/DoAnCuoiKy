
/// FILE: views/dashboard_tab.dart
/// GIAO DIỆN: TAB 1 - BẢNG ĐIỀU KHIỂN TỔNG QUAN (DASHBOARD TAB)
/// CHỨC NĂNG CHÍNH:
/// - Thẻ chào mừng & Thông tin tài khoản chủ trọ.
/// - Banner Doanh thu dự kiến tháng.
/// - Thẻ cảnh báo TỔNG CÔNG NỢ CHƯA THU (Hóa đơn PENDING).
/// - 3 Card thống kê tương tác: Phòng trống, Đang thuê, Tỷ lệ lấp đầy (%).
/// - Biểu đồ thống kê doanh thu 6 tháng gần nhất (`fl_chart`).
/// - Danh sách các phòng cần chốt tiền điện nước trong tháng.
/// - Lịch sử hóa đơn vừa lập gần đây.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/invoice_model.dart';
import '../models/room_model.dart';
import '../providers/auth_provider.dart';
import '../providers/rental_provider.dart';
import '../providers/settings_provider.dart';
import 'invoice_detail_dialog.dart';
import 'settings_screen.dart';
import 'widgets/billing_bottom_sheet.dart';
import 'widgets/revenue_chart_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  /// Mở BottomSheet chốt tiền điện nước cho một phòng
  void _openBillingBottomSheet(BuildContext context, Room room) {
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

  /// Mở Hộp thoại chi tiết hóa đơn & mã VietQR
  void _showInvoiceDetail(BuildContext context, Invoice inv) {
    showDialog(
      context: context,
      builder: (ctx) => InvoiceDetailDialog(invoice: inv),
    );
  }

  /// Mở danh sách chi tiết các phòng khi bấm vào các Card thống kê
  void _showRoomListModal(
    BuildContext context, {
    required String title,
    required List<Room> rooms,
    required Color primaryColor,
    required String emptyMessage,
    required IconData icon,
  }) {
    final loc = context.loc;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
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
                            icon,
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
                                        Text(
                                            loc.t('tenant_line', {
                                              'name': room.tenantName ??
                                                  loc.unknownTenant
                                            }),
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
                                        Text(
                                            loc.t('occupants_line', {
                                              'count': '${room.occupantCount}'
                                            }),
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '📅 ${loc.checkIn}: ${room.checkInDate != null ? dateFormat.format(room.checkInDate!) : loc.notSelected}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '🏁 ${loc.checkOut}: ${room.checkOutDate != null ? dateFormat.format(room.checkOutDate!) : loc.notSelected}',
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
                                        label: Text(loc.t('record_meter_btn')),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      loc.t('old_meter_line', {
                                        'elec': '${room.oldElectricity}',
                                        'water': '${room.oldWater}',
                                      }),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: room.status ==
                                                RoomStatus.available
                                            ? Colors.green.shade100
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        room.status == RoomStatus.available
                                            ? loc.t('room_ready_status')
                                            : '${loc.t('status_label')}: ${loc.roomStatus(room.status)}',
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

  /// Xây dựng Card thống kê tương tác (Phòng trống, Đang thuê, Tỷ lệ lấp đầy)
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        type: MaterialType.card,
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
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
    final settings = context.watch<SettingsProvider>();
    final loc = context.loc;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    final roleText =
        auth.userRole == 'Chủ trọ' ? loc.roleLandlord : auth.userRole;
    // Chỉ hiển thị vài hóa đơn mới nhất, xem đầy đủ ở tab Hóa đơn
    final recentInvoices = provider.invoices.take(5).toList();

    final availableRooms =
        provider.rooms.where((r) => r.status == RoomStatus.available).toList();
    final occupiedRooms =
        provider.rooms.where((r) => r.status == RoomStatus.occupied).toList();

    final monthlyStats = provider.getMonthlyRevenueStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ Chào mừng Chủ trọ + Nút Cài đặt nhanh
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
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
                        loc.t('greeting', {'name': auth.userName}),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${loc.t('role_line', {'role': roleText})} | ${auth.userEmail ?? ''}',
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

          // 2. Banner Doanh Thu Dự Kiến Tháng
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
                  currencyFormatter.format(
                      provider.expectedRevenueThisMonth(settings.serviceFee)),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.t('collected_this_month', {
                    'amount':
                        currencyFormatter.format(provider.collectedThisMonth),
                  }),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.t('expected_revenue_desc'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Card Cảnh báo TỔNG CÔNG NỢ CHƯA THU (Nếu có hóa đơn PENDING)
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

          // 4. 3 Thẻ thống kê tương tác (Phòng trống, Đang thuê, Lấp đầy %)
          Row(
            children: [
              _buildStatCard(
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
                    icon: Icons.meeting_room,
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
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
                    icon: Icons.group,
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
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
                    icon: Icons.pie_chart,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Biểu đồ Thống kê Doanh thu 6 Tháng (fl_chart)
          RevenueChartCard(monthlyStats: monthlyStats),
          const SizedBox(height: 24),

          // 6. Danh sách phòng cần chốt điện nước tháng này
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
                      '${loc.t('tenant_line', {'name': room.tenantName ?? loc.unknownTenant})}\n'
                      '${loc.t('old_meter_line', {'elec': '${room.oldElectricity}', 'water': '${room.oldWater}'})}',
                    ),
                    isThreeLine: true,
                    trailing: provider.hasInvoiceThisMonth(room.id)
                        ? Chip(
                            avatar: const Icon(Icons.check_circle,
                                color: Colors.green, size: 18),
                            label: Text(context.loc.billedThisMonth,
                                style: const TextStyle(fontSize: 12)),
                          )
                        : ElevatedButton(
                            onPressed: () =>
                                _openBillingBottomSheet(context, room),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: Text(loc.billingAction,
                                style: const TextStyle(fontSize: 13)),
                          ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // 7. Lịch sử Hóa đơn vừa lập gần đây
          if (recentInvoices.isNotEmpty) ...[
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
              itemCount: recentInvoices.length,
              itemBuilder: (context, index) {
                final inv = recentInvoices[index];
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
                        '${loc.createdDate}: $formattedDate\n${loc.t('status_label')}: ${loc.invoiceStatus(inv.status)}'),
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
