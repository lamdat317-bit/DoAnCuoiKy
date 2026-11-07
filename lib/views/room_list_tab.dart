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
  RoomStatus? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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

  void _openAddRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddRoomDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final loc = context.loc;

    final filteredRooms = provider.rooms.where((room) {
      // Status filter
      if (_selectedFilter != null && room.status != _selectedFilter) {
        return false;
      }
      // Text search filter
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.searchRoomHint,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3F51B5)),
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
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
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

          // Room List
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
                      return RoomCard(room: room);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddRoomDialog(context),
        icon: const Icon(Icons.add),
        label: Text(loc.addNewRoom),
      ),
    );
  }
}
