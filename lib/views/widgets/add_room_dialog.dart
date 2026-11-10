import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/room_model.dart';
import '../../providers/rental_provider.dart';

class AddRoomDialog extends StatefulWidget {
  final Room? roomToEdit;

  const AddRoomDialog({super.key, this.roomToEdit});

  @override
  State<AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _elecController;
  late final TextEditingController _waterController;
  late final TextEditingController _tenantController;
  late final TextEditingController _phoneController;
  late final TextEditingController _occupantController;
  late final TextEditingController _depositController;

  late RoomStatus _selectedStatus;
  String? _imageUrl;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  final ImagePicker _picker = ImagePicker();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1598928506311-c55ded91a20c?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=600&auto=format&fit=crop&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.roomToEdit;
    _nameController = TextEditingController(text: r?.name ?? '');
    _priceController =
        TextEditingController(text: r != null ? r.basePrice.toStringAsFixed(0) : '');
    _elecController =
        TextEditingController(text: r != null ? r.oldElectricity.toString() : '');
    _waterController =
        TextEditingController(text: r != null ? r.oldWater.toString() : '');
    _tenantController = TextEditingController(text: r?.tenantName ?? '');
    _phoneController = TextEditingController(text: r?.phone ?? '');
    _occupantController =
        TextEditingController(text: (r?.occupantCount ?? 1).toString());
    _depositController = TextEditingController(
        text: r != null ? r.depositAmount.toStringAsFixed(0) : '0');
    _selectedStatus = r?.status ?? RoomStatus.available;
    _imageUrl = r?.imageUrl;
    _checkInDate = r?.checkInDate;
    _checkOutDate = r?.checkOutDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _elecController.dispose();
    _waterController.dispose();
    _tenantController.dispose();
    _phoneController.dispose();
    _occupantController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final loc = context.loc;
    final initialDate = isCheckIn
        ? (_checkInDate ?? DateTime.now())
        : (_checkOutDate ?? DateTime.now().add(const Duration(days: 365)));

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
      helpText: isCheckIn ? loc.checkInDateLabel.toUpperCase() : loc.checkOutDateLabel.toUpperCase(),
      confirmText: loc.confirm.toUpperCase(),
      cancelText: loc.cancel.toUpperCase(),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUrlInputDialog() {
    final loc = context.loc;
    final urlController = TextEditingController(text: _imageUrl ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'URL',
            hintText: 'https://example.com/room.jpg',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final text = urlController.text.trim();
              setState(() {
                _imageUrl = text.isNotEmpty ? text : null;
              });
              Navigator.pop(ctx);
            },
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  void _showSampleImagesPicker() {
    final loc = context.loc;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                loc.samplePhotos,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                itemBuilder: (context, index) {
                  final img = _sampleImages[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageUrl = img;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _imageUrl == img
                              ? const Color(0xFF3F51B5)
                              : Colors.grey.shade300,
                          width: _imageUrl == img ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(img),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    final loc = context.loc;
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final elec = int.parse(_elecController.text.trim());
      final water = int.parse(_waterController.text.trim());
      final tenant = _tenantController.text.trim();
      final phone = _phoneController.text.trim();
      final occupants = int.tryParse(_occupantController.text.trim()) ?? 1;
      final deposit = double.tryParse(_depositController.text.trim()) ?? 0.0;

      final isEditing = widget.roomToEdit != null;

      final roomData = Room(
        id: isEditing
            ? widget.roomToEdit!.id
            : 'room_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        basePrice: price,
        status: _selectedStatus,
        tenantName:
            _selectedStatus == RoomStatus.occupied && tenant.isNotEmpty ? tenant : null,
        phone:
            _selectedStatus == RoomStatus.occupied && phone.isNotEmpty ? phone : null,
        oldElectricity: elec,
        oldWater: water,
        imageUrl: _imageUrl,
        occupantCount: _selectedStatus == RoomStatus.occupied ? occupants : 1,
        checkInDate: _selectedStatus == RoomStatus.occupied ? _checkInDate : null,
        checkOutDate: _selectedStatus == RoomStatus.occupied ? _checkOutDate : null,
        depositAmount: _selectedStatus == RoomStatus.occupied ? deposit : 0.0,
      );

      final provider = context.read<RentalProvider>();
      if (isEditing) {
        provider.updateRoom(roomData);
      } else {
        provider.addRoom(roomData);
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.roomSavedSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildImagePreview() {
    final loc = context.loc;
    if (_imageUrl == null || _imageUrl!.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                loc.addRoomImage,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final isNetwork =
        _imageUrl!.startsWith('http://') || _imageUrl!.startsWith('https://');

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: isNetwork
              ? Image.network(
                  _imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                  ),
                )
              : Image.file(
                  File(_imageUrl!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 160,
                    color: Colors.grey.shade200,
                    child: const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                  ),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            radius: 18,
            child: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.white),
              onPressed: () {
                setState(() {
                  _imageUrl = null;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    final isEditing = widget.roomToEdit != null;

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
                    isEditing ? loc.dialogEditRoom : loc.dialogAddRoom,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3F51B5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image Preview Area
              _buildImagePreview(),
              const SizedBox(height: 8),

              // Image Source Selection Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text(loc.takePhoto, style: const TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: Text(loc.chooseFromGallery, style: const TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _showSampleImagesPicker,
                    icon: const Icon(Icons.collections, size: 18),
                    label: const Text('Samples', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: _showUrlInputDialog,
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text('URL', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const Divider(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '${loc.roomNameLabel} *',
                  hintText: loc.roomNameHint,
                  prefixIcon: const Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${loc.basePriceLabel} *',
                  hintText: '3500000',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.requiredField;
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return loc.invalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _elecController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${loc.initialElecLabel} *',
                        hintText: 'kWh',
                        prefixIcon: const Icon(Icons.flash_on),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return loc.invalidNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _waterController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '${loc.initialWaterLabel} *',
                        hintText: 'm³',
                        prefixIcon: const Icon(Icons.water_drop),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return loc.requiredField;
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return loc.invalidNumber;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<RoomStatus>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: loc.roomStatusLabel,
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                items: RoomStatus.values.map((status) {
                  return DropdownMenuItem<RoomStatus>(
                    value: status,
                    child: Text(loc.roomStatus(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),

              // Customer / Occupant details section when room is occupied
              if (_selectedStatus == RoomStatus.occupied) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.tenantInfoHeader,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tenantController,
                        decoration: InputDecoration(
                          labelText: loc.tenantNameLabel,
                          hintText: 'Nguyễn Văn A',
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: loc.tenantPhoneLabel,
                                hintText: '0901234567',
                                prefixIcon: const Icon(Icons.phone),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _occupantController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: loc.occupantCountLabel,
                                hintText: '2',
                                prefixIcon: const Icon(Icons.group),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.depositLabel,
                          hintText: '3500000',
                          prefixIcon: const Icon(Icons.lock, color: Colors.amber),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Check-in & Check-out dates selection
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(loc.checkInDateLabel,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 14, color: Color(0xFF3F51B5)),
                                        const SizedBox(width: 6),
                                        Text(
                                          _checkInDate != null
                                              ? _dateFormat.format(_checkInDate!)
                                              : loc.pickDate,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(loc.checkOutDateLabel,
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_busy,
                                            size: 14, color: Colors.red),
                                        const SizedBox(width: 6),
                                        Text(
                                          _checkOutDate != null
                                              ? _dateFormat.format(_checkOutDate!)
                                              : loc.pickDate,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600),
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
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(isEditing ? Icons.save_as : Icons.save, color: Colors.white),
                label: Text(
                  loc.saveRoomBtn,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
