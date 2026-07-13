import 'supabase_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._();
  factory ProfileService() => _instance;
  ProfileService._();

  final _sb = SupabaseService().client;

  Future<void> loadProfile() async {
    final userId = AuthService().currentUser?.id;
    if (userId == null) return;

    try {
      final res = await _sb.from('profiles').select().eq('user_id', userId).maybeSingle();
      if (res != null) {
        final storage = StorageService();
        final name = res['name'] as String?;
        if (name != null && name.isNotEmpty && name != '赏花人') {
          storage.setProfileName(name);
        }
        storage.setBirthday(res['birthday'] as String?);
        storage.setBio(res['bio'] as String?);
      }
    } catch (_) {}
  }

  Future<void> saveProfile({
    required String name,
    String? birthday,
    String? bio,
  }) async {
    final userId = AuthService().currentUser?.id;
    if (userId == null) return;

    try {
      await _sb.from('profiles').upsert({
        'user_id': userId,
        'name': name,
        'birthday': birthday,
        'bio': bio,
        'updated_at': DateTime.now().toIso8601String(),
      });

      final storage = StorageService();
      storage.setProfileName(name);
      storage.setBirthday(birthday);
      storage.setBio(bio);
    } catch (_) {
      // Still save locally if Supabase fails
      final storage = StorageService();
      storage.setProfileName(name);
      storage.setBirthday(birthday);
      storage.setBio(bio);
    }
  }
}
