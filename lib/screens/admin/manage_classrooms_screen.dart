import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../utils/theme.dart';

class ManageClassroomsScreen extends StatefulWidget {
  const ManageClassroomsScreen({super.key});

  @override
  State<ManageClassroomsScreen> createState() => _ManageClassroomsScreenState();
}

class _ManageClassroomsScreenState extends State<ManageClassroomsScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<dynamic> _classrooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final cr = await _apiService.getClassrooms();
      if (mounted) {
        setState(() {
          _classrooms = cr;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _roomTypeOptions(String? currentType) {
    const roomTypes = ['Phòng lý thuyết', 'Phòng thực hành', 'Hội trường'];
    if (currentType == null ||
        currentType.isEmpty ||
        roomTypes.contains(currentType)) {
      return roomTypes;
    }
    return [currentType, ...roomTypes];
  }

  void _showClassroomDialog([dynamic classroom]) {
    final isEditing = classroom != null;
    final nameController = TextEditingController(text: classroom?['tenPhong']);
    final buildingController = TextEditingController(
      text: classroom?['toaNha'],
    );
    final capacityController = TextEditingController(
      text: classroom?['sucChua']?.toString(),
    );

    String? selectedType = classroom?['loaiPhong'] ?? 'Phòng lý thuyết';
    final roomTypes = _roomTypeOptions(selectedType);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditing ? 'Sửa Phòng Học' : 'Thêm Phòng Học',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên Phòng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.room),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: buildingController,
                      decoration: InputDecoration(
                        labelText: 'Tòa nhà',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: capacityController,
                      decoration: InputDecoration(
                        labelText: 'Sức chứa',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Loại phòng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: roomTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          selectedType = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        buildingController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập đầy đủ thông tin'),
                        ),
                      );
                      return;
                    }

                    final data = {
                      'tenPhong': nameController.text,
                      'toaNha': buildingController.text,
                      'sucChua': int.tryParse(capacityController.text) ?? 0,
                      'loaiPhong': selectedType,
                    };

                    bool success;
                    if (isEditing) {
                      success = await _apiService.updateClassroom(
                        classroom['id'],
                        data,
                      );
                    } else {
                      success = await _apiService.createClassroom(data);
                    }

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                      _loadData();
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lưu thông tin thất bại!'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteClassroom(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa phòng học này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _apiService.deleteClassroom(id);
      if (success) {
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Lỗi: Không thể xóa phòng học này do đang được sử dụng.',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Phòng học'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classrooms.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu phòng học'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _classrooms.length,
              itemBuilder: (context, index) {
                final c = _classrooms[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: const Icon(
                        Icons.room,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    title: Text(
                      c['tenPhong'] ?? 'Không tên',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Tòa nhà: ${c['toaNha'] ?? ''}\nSức chứa: ${c['sucChua'] ?? 0} | ${c['loaiPhong'] ?? ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showClassroomDialog(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteClassroom(c['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () => _showClassroomDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
