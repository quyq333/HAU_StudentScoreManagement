import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/subject_model.dart';
import '../../utils/theme.dart';

class AdminSubjectMaterialsScreen extends StatefulWidget {
  final SubjectModel subject;

  const AdminSubjectMaterialsScreen({
    super.key,
    required this.subject,
  });

  @override
  State<AdminSubjectMaterialsScreen> createState() => _AdminSubjectMaterialsScreenState();
}

class _AdminSubjectMaterialsScreenState extends State<AdminSubjectMaterialsScreen> {
  final AdminApiService _apiService = AdminApiService();
  List<dynamic> _materials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getMaterialsBySubject(widget.subject.maMonHoc);
      if (mounted) {
        setState(() {
          _materials = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMaterialDialog([Map<String, dynamic>? material]) {
    final isEditing = material != null;
    final formKey = GlobalKey<FormState>();

    String? selectedLoaiTaiLieu = material != null ? material['loaiTaiLieu'] : 'PDF';

    final tenController = TextEditingController(
      text: material != null ? material['tenTaiLieu'] : '',
    );
    final duongDanController = TextEditingController(
      text: material != null ? material['duongDan'] : '',
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'Sửa Tài Liệu' : 'Thêm Tài Liệu Mới',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Môn học', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      widget.subject.tenMonHoc,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Loại tài liệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedLoaiTaiLieu,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'PDF', child: Text('PDF')),
                      DropdownMenuItem(value: 'DOCX', child: Text('DOCX (Word)')),
                      DropdownMenuItem(value: 'LINK', child: Text('LINK (Drive/Web)')),
                      DropdownMenuItem(value: 'VIDEO', child: Text('VIDEO (Bài giảng)')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedLoaiTaiLieu = val;
                      });
                    },
                    validator: (val) => val == null ? 'Vui lòng chọn loại tài liệu' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: tenController,
                    decoration: InputDecoration(
                      labelText: 'Tên tài liệu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Không được bỏ trống' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: duongDanController,
                    decoration: InputDecoration(
                      labelText: 'Đường dẫn liên kết (URL)',
                      helperText: 'Ví dụ: https://drive.google.com/...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Không được bỏ trống';
                      }
                      if (!val.startsWith('http://') && !val.startsWith('https://')) {
                        return 'Đường dẫn phải bắt đầu bằng http:// hoặc https://';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final Map<String, dynamic> data = {
                    'tenTaiLieu': tenController.text,
                    'loaiTaiLieu': selectedLoaiTaiLieu,
                    'duongDan': duongDanController.text,
                    'maMonHoc': widget.subject.maMonHoc,
                  };

                  bool success;
                  if (isEditing) {
                    success = await _apiService.updateMaterial(material['id'], data);
                  } else {
                    success = await _apiService.createMaterial(data);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Cập nhật tài liệu thành công' : 'Thêm tài liệu thành công')),
                      );
                      _loadMaterials();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Có lỗi xảy ra khi lưu tài liệu')),
                      );
                    }
                  }
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMaterial(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa tài liệu "$name" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final success = await _apiService.deleteMaterial(id);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Xóa tài liệu thành công')),
                  );
                  _loadMaterials();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không thể xóa tài liệu')),
                  );
                }
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'PDF':
        return Colors.red.shade600;
      case 'DOCX':
      case 'DOC':
        return Colors.blue.shade600;
      case 'VIDEO':
        return Colors.purple.shade600;
      default:
        return Colors.teal.shade600;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'PDF':
        return Icons.picture_as_pdf_rounded;
      case 'DOCX':
      case 'DOC':
        return Icons.description_rounded;
      case 'VIDEO':
        return Icons.play_circle_fill_rounded;
      default:
        return Icons.insert_link_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Quản lý Tài liệu'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card showing Subject details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.subject.maMonHoc,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.subject.tenMonHoc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.folder_shared_rounded, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${_materials.length} tài liệu học tập',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Materials List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _materials.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _materials.length,
                        itemBuilder: (context, index) {
                          final m = _materials[index];
                          final typeColor = _getTypeColor(m['loaiTaiLieu']);
                          final typeIcon = _getTypeIcon(m['loaiTaiLieu']);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Icon type
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      typeIcon,
                                      color: typeColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Content details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['tenTaiLieu'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: typeColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                m['loaiTaiLieu'] ?? 'LINK',
                                                style: TextStyle(
                                                  color: typeColor,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'URL: ${m['duongDan'] ?? ''}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Edit & Delete actions
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                                        onPressed: () => _showMaterialDialog(m),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                                        onPressed: () => _deleteMaterial(m['id'], m['tenTaiLieu'] ?? ''),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () => _showMaterialDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 72,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tài liệu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Môn học này hiện chưa có tài liệu học tập nào. Nhấp "+" để thêm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
