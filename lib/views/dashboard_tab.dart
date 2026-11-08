/// ============================================================================
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
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/invoice_model.dart';
import '../models/room_model.dart';
import '../providers/auth_provider.dart';
import '../providers/rental_provider.dart';
import 'invoice_detail_dialog.dart';
import 'settings_screen.dart';
import 'widgets/billing_bottom_sheet.dart';
import 'widgets/revenue_chart_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  /// Mở BottomSheet chốt tiền điện nước cho một phòng
  void _openBillingBottomSheet(BuildContext context, Room room) {
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
  }) {
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
          decoration: const BoxDecoration(
            color: Colors.white,
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
                            title.contains('trống')
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
                                        Text('Khách: ${room.tenantName ?? 'N/A'}',
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
                                        Text('Số người ở: ${room.occupantCount} người',
                                            style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '📅 Vào ở: ${room.checkInDate != null ? dateFormat.format(room.checkInDate!) : 'N/A'}',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade700),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '🏁 Out: ${room.checkOutDate != null ? dateFormat.format(room.checkOutDate!) : 'N/A'}',
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
                                        label: const Text('Chốt tiền điện nước'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Chỉ số điện cũ: ${room.oldElectricity} kWh | Nước cũ: ${room.oldWater} m³',
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
                                        'Trạng thái: Trống (Sẵn sàng cho thuê)',
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
        color: Colors.white,
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
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

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
              color: Colors.white,
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
                        'Xin chào, ${auth.userName} 👋',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vai trò: ${auth.userRole} | ${auth.userEmail ?? ''}',
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
                  tooltip: 'Cài đặt Biểu phí & VietQR',
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
                    const Text(
                      'DOANH THU DỰ KIẾN THÁNG',
                      style: TextStyle(
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
                const Text(
                  'Dựa trên các phòng đang cho thuê',
                  style: TextStyle(
                    fontSize: 13,
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
                        const Text(
                          'TỔNG CÔNG NỢ CHƯA THU',
                          style: TextStyle(
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
                          'Hiện có ${provider.unpaidInvoicesCount} hóa đơn chưa thanh toán',
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
                title: 'Phòng trống',
                value: '${provider.availableCount}',
                icon: Icons.meeting_room_outlined,
                color: Colors.green,
                onTap: () {
                  _showRoomListModal(
                    context,
                    title: 'Danh sách Phòng trống',
                    rooms: availableRooms,
                    primaryColor: Colors.green,
                    emptyMessage: 'Hiện không có phòng nào đang trống',
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                title: 'Đang thuê',
                value: '${provider.occupiedCount}',
                icon: Icons.people_outline,
                color: Colors.orange,
                onTap: () {
                  _showRoomListModal(
                    context,
                    title: 'Danh sách Phòng đang thuê',
                    rooms: occupiedRooms,
                    primaryColor: Colors.orange.shade900,
                    emptyMessage: 'Hiện chưa có phòng nào đang thuê',
                  );
                },
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                title: 'Lấp đầy',
                value: '${provider.occupancyRate.toStringAsFixed(0)}%',
                icon: Icons.pie_chart_outline,
                color: const Color(0xFF3F51B5),
                onTap: () {
                  _showRoomListModal(
                    context,
                    title: 'Tỷ lệ Lấp đầy & Toàn bộ phòng',
                    rooms: provider.rooms,
                    primaryColor: const Color(0xFF3F51B5),
                    emptyMessage: 'Chưa có dữ liệu phòng',
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
          const Text(
            'Phòng cần chốt điện nước tháng này',
            style: TextStyle(
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Hiện chưa có phòng nào đang thuê',
                style: TextStyle(color: Colors.grey),
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
                      'Khách: ${room.tenantName ?? 'Chưa rõ'}\nĐiện cũ: ${room.oldElectricity} kWh | Nước cũ: ${room.oldWater} m³',
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
                      child: const Text('Tính tiền', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // 7. Lịch sử Hóa đơn vừa lập gần đây
          if (provider.invoices.isNotEmpty) ...[
            const Text(
              'Hóa đơn vừa lập gần đây',
              style: TextStyle(
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
                        'Ngày tạo: $formattedDate\nTrạng thái: ${inv.status.displayName}'),
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
