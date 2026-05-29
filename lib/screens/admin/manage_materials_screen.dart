import 'package:flutter/material.dart';
import '../../services/admin_api_service.dart';
import '../../models/subject_model.dart';
import '../../utils/theme.dart';
import 'admin_subject_materials_screen.dart';

class ManageMaterialsScreen extends StatefulWidget {
  const ManageMaterialsScreen({super.key});

  @override
  State<ManageMaterialsScreen> createState() => _ManageMaterialsScreenState();
}

class _ManageMaterialsScreenState extends State<ManageMaterialsScreen> {
  final AdminApiService _apiService = AdminApiService();
  final TextEditingController _searchController = TextEditingController();

  List<SubjectModel> _subjects = [];
  List<dynamic> _materials = [];
  List<SubjectModel> _filteredSubjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final mt = await _apiService.getMaterials();
      final subs = await _apiService.getSubjects();
      if (mounted) {
        setState(() {
          _materials = mt;
          _subjects = subs;
          _filteredSubjects = _subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSubjects(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSubjects = _subjects;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredSubjects = _subjects.where((sub) {
        return sub.tenMonHoc.toLowerCase().contains(lowercaseQuery) ||
               sub.maMonHoc.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  List<dynamic> _getMaterialsForSubject(String subjectCode) {
    return _materials.where((m) => m['subject']?['maMonHoc'] == subjectCode).toList();
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterSubjects,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm môn học...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _filterSubjects('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Subjects List
                Expanded(
                  child: _filteredSubjects.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredSubjects.length,
                          itemBuilder: (context, index) {
                            final subject = _filteredSubjects[index];
                            final subjectMaterials = _getMaterialsForSubject(subject.maMonHoc);
                            final hasMaterials = subjectMaterials.isNotEmpty;

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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminSubjectMaterialsScreen(
                                          subject: subject,
                                        ),
                                      ),
                                    ).then((_) => _loadData()); // Refresh material counts when back
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Left Icon
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryBlue.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.folder_shared_rounded,
                                            color: AppTheme.primaryBlue,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Subject Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                subject.tenMonHoc,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Mã: ${subject.maMonHoc} • ${subject.soTinChi} Tín chỉ',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Badge count
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: hasMaterials
                                                    ? AppTheme.primaryBlue.withOpacity(0.1)
                                                    : Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                hasMaterials
                                                    ? '${subjectMaterials.length} tài liệu'
                                                    : 'Trống',
                                                style: TextStyle(
                                                  color: hasMaterials
                                                      ? AppTheme.primaryBlue
                                                      : Colors.grey.shade600,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 12,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'Không tìm thấy môn học nào'
                : 'Chưa có môn học nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

