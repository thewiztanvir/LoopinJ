import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_text_field.dart';
import '../../../core/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chat/providers/chat_provider.dart';

class FindConnectionsScreen extends ConsumerStatefulWidget {
  const FindConnectionsScreen({super.key});

  @override
  ConsumerState<FindConnectionsScreen> createState() => _FindConnectionsScreenState();
}

class _FindConnectionsScreenState extends ConsumerState<FindConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if(mounted) setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      // Basic prefix query on displayName
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      final currentUserId = ref.read(authServiceProvider).currentUserId;
      final results = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.uid != currentUserId) // Filter out self
          .toList();

      if(mounted) setState(() => _searchResults = results);
    } catch (e) {
      print('Search error: $e');
    } finally {
      if(mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _startChatLoop(UserModel targetUser) async {
    try {
      // 1. Get or create the chat room ID
      final chatRoomId = await ref.read(chatServiceProvider).createOrGetChatRoom(targetUser.uid);
      
      // 2. Navigate straight into it
      if (mounted) {
        context.push('/chat/$chatRoomId');
      }
    } catch (e) {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start loop: $e')));
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Find Connections', style: TextStyle(color: AppColors.primaryNeon)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNeon),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1550684848-fac1c5b4e853?q=80&w=2564&auto=format&fit=crop'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassTextField(
                  controller: _searchController,
                  hintText: 'Search Neon IDs...',
                  prefixIcon: Icons.search,
                ),
              ),
              const SizedBox(height: 10),
              
              // Fake button to trigger search instead of using onChange for performance on huge DB
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryNeon.withOpacity(0.2),
                      foregroundColor: AppColors.secondaryNeon,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.secondaryNeon))
                    ),
                    onPressed: () => _performSearch(_searchController.text),
                    child: const Text('SCAN NETWORK'),
                  )
                ),
              ),
              const SizedBox(height: 20),

              if (_isSearching)
                const CircularProgressIndicator(color: AppColors.primaryNeon)
              else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No connections found in the database.', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.glassmorphismBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassmorphismBorder),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.background,
                            backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                            child: user.photoUrl == null ? Icon(Icons.person, color: AppColors.primaryNeon) : null,
                          ),
                          title: Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          subtitle: Text('ID: ${user.uid.substring(0, 8)}...', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryNeon),
                            onPressed: () => _startChatLoop(user),
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
}
