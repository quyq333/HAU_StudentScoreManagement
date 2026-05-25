import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../utils/theme.dart';

class ManageMaterialsScreen extends StatefulWidget {
  const ManageMaterialsScreen({super.key});

  @override
  State<ManageMaterialsScreen> createState() => _ManageMaterialsScreenState();
}

class _ManageMaterialsScreenState extends State<ManageMaterialsScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<dynamic> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final mt = await _apiService.getMaterials();
      if (mounted) {
        setState(() {
          _materials = mt;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Tài liệu'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _materials.isEmpty
            ? const Center(child: Text('Chưa có dữ liệu tài liệu'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _materials.length,
                itemBuilder: (context, index) {
                  final m = _materials[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: const Icon(Icons.description, color: Colors.orange),
                      ),
                      title: Text(m['tenTaiLieu'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Loại: ${m['loaiTaiLieu'] ?? ''}\nMôn: ${m['subject']?['tenMonHoc'] ?? ''}'),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chức năng thêm mới đang được cập nhật!')),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
