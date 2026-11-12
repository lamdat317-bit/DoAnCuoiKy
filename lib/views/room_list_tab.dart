/// ============================================================================
/// FILE: views/room_list_tab.dart
/// GIAO DIỆN: TAB 2 - DANH SÁCH PHÒNG TRỌ (ROOM LIST TAB)
/// ----------------------------------------------------------------------------
/// NGHỆP VỤ & THÀNH PHẦN TRÊN MÀN HÌNH NÀY:
/// 1. Ô TÌM KIẾM TÌM PHÒNG (TextField): Tìm nhanh phòng theo Tên, Tên Khách hoặc SĐT.
/// 2. BỘ LỌC THẺ THÔNG MINH (FilterChip): Lọc danh sách phòng theo Trống / Đang thuê / Bảo trì.
/// 3. DANH SÁCH THẺ PHÒNG (ListView.builder & RoomCard): Hiển thị từng căn phòng.
/// 4. NÚT TRÒN THÊM PHÒNG (FloatingActionButton): Nút "+ Thêm phòng mới" mở AddRoomDialog.
/// ============================================================================
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/room_model.dart';
import '../providers/rental_provider.dart';
import 'widgets/add_room_dialog.dart';
import 'widgets/room_card.dart';

class RoomListTab extends StatefulWidget {
  const RoomListTab({super.key});

  @override
  State<RoomListTab> createState() => _RoomListTabState();
}

class _RoomListTabState extends State<RoomListTab> {
  // Biến lưu bộ lọc trạng thái phòng đang chọn (null = Xem tất cả)
  RoomStatus? _selectedFilter;

  // Bộ điều khiển nhập dữ liệu từ ô tìm kiếm văn bản
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Lắng nghe sự thay đổi khi người dùng gõ vào ô tìm kiếm để lọc danh sách
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// [HÀM XỬ LÝ]: Mở Hộp thoại Thêm phòng trọ mới (AddRoomDialog)
  void _openAddRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddRoomDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đọc danh sách phòng từ RentalProvider & Bộ ngôn ngữ từ AppLocalizations
    final provider = context.watch<RentalProvider>();
    final loc = context.loc;

    // LOGIC LỌC PHÒNG TRỌ: Lọc kết hợp giữa Bộ lọc Trạng thái (FilterChip) và Từ khóa tìm kiếm
    final filteredRooms = provider.rooms.where((room) {
      if (_selectedFilter != null && room.status != _selectedFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final matchesName = room.name.toLowerCase().contains(_searchQuery);
        final matchesTenant =
            room.tenantName?.toLowerCase().contains(_searchQuery) ?? false;
        final matchesPhone = room.phone?.contains(_searchQuery) ?? false;
        return matchesName || matchesTenant || matchesPhone;
      }
      return true;
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // ===================================================================
          // GIAO DIỆN 1: Ô TÌM KIẾM PHÒNG TRỌ (TextField Tìm kiếm)
          // ===================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.searchRoomHint,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3F51B5)),
                // Nút Xóa từ khóa tìm kiếm (khi ô tìm kiếm có chữ)
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ===================================================================
          // GIAO DIỆN 2: BỘ LỌC TRẠNG THÁI PHÒNG TRỌ (Thẻ FilterChip)
          // ===================================================================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // NÚT LỌC 1: Tất cả các phòng
                FilterChip(
                  label: Text('${loc.filterAll} (${provider.totalRooms})'),
                  selected: _selectedFilter == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                  selectedColor: const Color(0x333F51B5),
                  checkmarkColor: const Color(0xFF3F51B5),
                ),
                const SizedBox(width: 8),
                // NÚT LỌC 2: Chỉ xem Phòng Trống (Available)
                FilterChip(
                  label: Text('${loc.filterAvailable} (${provider.availableCount})'),
                  selected: _selectedFilter == RoomStatus.available,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? RoomStatus.available : null;
                    });
                  },
                  selectedColor: Colors.green.shade100,
                  checkmarkColor: Colors.green.shade900,
                ),
                const SizedBox(width: 8),
                // NÚT LỌC 3: Chỉ xem Phòng Đang Thuê (Occupied)
                FilterChip(
                  label: Text('${loc.filterOccupied} (${provider.occupiedCount})'),
                  selected: _selectedFilter == RoomStatus.occupied,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? RoomStatus.occupied : null;
                    });
                  },
                  selectedColor: Colors.orange.shade100,
                  checkmarkColor: Colors.orange.shade900,
                ),
                const SizedBox(width: 8),
                // NÚT LỌC 4: Chỉ xem Phòng Đang Bảo Trì (Maintenance)
                FilterChip(
                  label: Text('${loc.filterMaintenance} (${provider.maintenanceCount})'),
                  selected: _selectedFilter == RoomStatus.maintenance,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? RoomStatus.maintenance : null;
                    });
                  },
                  selectedColor: Colors.grey.shade300,
                  checkmarkColor: Colors.grey.shade900,
                ),
              ],
            ),
          ),

          // ===================================================================
          // GIAO DIỆN 3: DANH SÁCH CÁC THẺ PHÒNG TRỌ (ListView.builder & RoomCard)
          // ===================================================================
          Expanded(
            child: filteredRooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.noRoomsFound,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      // Gọi Widget RoomCard hiển thị thẻ thông tin từng căn phòng
                      return RoomCard(room: room);
                    },
                  ),
          ),
        ],
      ),

      // =======================================================================
      // GIAO DIỆN 4: NÚT TRÒN THÊM PHÒNG MỚI (FloatingActionButton)
      // =======================================================================
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRoomDialog(context),
        icon: const Icon(Icons.add),
        label: Text(loc.addNewRoom),
      ),
    );
  }
}
