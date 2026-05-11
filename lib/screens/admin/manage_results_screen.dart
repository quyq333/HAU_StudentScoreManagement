import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';

class ManageResultsScreen extends StatefulWidget {
  const ManageResultsScreen({super.key});

  @override
  State<ManageResultsScreen> createState() => _ManageResultsScreenState();
}

class _ManageResultsScreenState extends State<ManageResultsScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    final data = await _apiService.getResults();
    setState(() {
      _results = data;
      _isLoading = false;
    });
  }

  void _showResultDialog([Map<String, dynamic>? result]) {
    final isEditing = result != null;
    final svController = TextEditingController(text: result?['student']?['maSV']);
    final mhController = TextEditingController(text: result?['subject']?['maMonHoc']);
    final hkController = TextEditingController(text: result?['semester']?['id']?.toString());
    
    final ccController = TextEditingController(text: result?['diemChuyenCan']?.toString());
    final ktController = TextEditingController(text: result?['diemKiemTra']?.toString());
    final thiController = TextEditingController(text: result?['diemThi']?.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Sửa Điểm' : 'Thêm Điểm'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing) ...[
                TextField(controller: svController, decoration: const InputDecoration(labelText: 'Mã SV')),
                TextField(controller: mhController, decoration: const InputDecoration(labelText: 'Mã Môn Học')),
                TextField(controller: hkController, decoration: const InputDecoration(labelText: 'ID Học Kỳ')),
              ],
              TextField(controller: ccController, decoration: const InputDecoration(labelText: 'Điểm CC'), keyboardType: TextInputType.number),
              TextField(controller: ktController, decoration: const InputDecoration(labelText: 'Điểm KT'), keyboardType: TextInputType.number),
              TextField(controller: thiController, decoration: const InputDecoration(labelText: 'Điểm Thi'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              // Tự động tính điểm tổng kết và điểm chữ cơ bản (bạn có thể đưa logic này lên Backend)
              double? cc = double.tryParse(ccController.text);
              double? kt = double.tryParse(ktController.text);
              double? thi = double.tryParse(thiController.text);
              
              double tk = 0.0;
              if (cc != null && kt != null && thi != null) {
                tk = (cc * 0.1) + (kt * 0.2) + (thi * 0.7);
              }

              String diemChu = 'F';
              if (tk >= 8.5) diemChu = 'A';
              else if (tk >= 8.0) diemChu = 'B+';
              else if (tk >= 7.0) diemChu = 'B';
              else if (tk >= 6.5) diemChu = 'C+';
              else if (tk >= 5.5) diemChu = 'C';
              else if (tk >= 5.0) diemChu = 'D+';
              else if (tk >= 4.0) diemChu = 'D';

              final data = {
                'diemChuyenCan': cc,
                'diemKiemTra': kt,
                'diemThi': thi,
                'diemTongKet': double.parse(tk.toStringAsFixed(1)),
                'diemChu': diemChu,
              };

              if (!isEditing) {
                data['maSV'] = svController.text;
                data['maMonHoc'] = mhController.text;
                data['idHocKy'] = int.tryParse(hkController.text) ?? 1;
              }

              bool success;
              if (isEditing) {
                success = await _apiService.updateResult(result['id'], data);
              } else {
                success = await _apiService.createResult(data);
              }

              if (success) {
                if (context.mounted) Navigator.pop(context);
                _loadResults();
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi: Sai mã SV, Môn học hoặc Học kỳ!')));
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteResult(int id) async {
    final success = await _apiService.deleteResult(id);
    if (success) {
      _loadResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Điểm Số')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                final sv = result['student']?['hoTen'] ?? '';
                final mh = result['subject']?['tenMonHoc'] ?? '';
                return ListTile(
                  leading: CircleAvatar(child: Text(result['diemChu'] ?? '-')),
                  title: Text('$sv - $mh'),
                  subtitle: Text('CC: ${result['diemChuyenCan']} | KT: ${result['diemKiemTra']} | Thi: ${result['diemThi']} \nTổng: ${result['diemTongKet']}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showResultDialog(result),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteResult(result['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showResultDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
