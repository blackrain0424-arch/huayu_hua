import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/browse_record.dart';
import '../models/upload_record.dart';

class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  SharedPreferences? _prefs;
  bool _initialized = false;

  static const _browseKey = 'browse_records';
  static const _uploadKey = 'upload_records';
  static const _favKey = 'favorites';
  static const _profileNameKey = 'profile_name';
  static const _birthdayKey = 'profile_birthday';
  static const _bioKey = 'profile_bio';
  static const _maxRecords = 50;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  void _ensureInit() {
    if (!_initialized || _prefs == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
  }

  // ========== 浏览记录 ==========

  List<BrowseRecord> getBrowseRecords() {
    _ensureInit();
    final raw = _prefs!.getString(_browseKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => BrowseRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  void addBrowseRecord(BrowseRecord record) {
    _ensureInit();
    final records = getBrowseRecords();
    records.removeWhere((r) => r.spotName == record.spotName);
    records.insert(0, record);
    if (records.length > _maxRecords) {
      records.removeRange(_maxRecords, records.length);
    }
    _saveBrowseRecords(records);
  }

  void clearBrowseRecords() {
    _ensureInit();
    _prefs!.remove(_browseKey);
  }

  void _saveBrowseRecords(List<BrowseRecord> records) {
    _ensureInit();
    final json = records.map((r) => r.toJson()).toList();
    _prefs!.setString(_browseKey, jsonEncode(json));
  }

  // ========== 上传记录 ==========

  List<UploadRecord> getUploadRecords() {
    _ensureInit();
    final raw = _prefs!.getString(_uploadKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => UploadRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  void addUploadRecord(UploadRecord record) {
    _ensureInit();
    final records = getUploadRecords();
    records.insert(0, record);
    if (records.length > _maxRecords) {
      records.removeRange(_maxRecords, records.length);
    }
    _saveUploadRecords(records);
  }

  void clearUploadRecords() {
    _ensureInit();
    _prefs!.remove(_uploadKey);
  }

  void _saveUploadRecords(List<UploadRecord> records) {
    _ensureInit();
    final json = records.map((r) => r.toJson()).toList();
    _prefs!.setString(_uploadKey, jsonEncode(json));
  }

  // ========== 收藏 ==========

  Set<String> getFavorites() {
    _ensureInit();
    final raw = _prefs!.getStringList(_favKey);
    if (raw == null) return {};
    return raw.toSet();
  }

  bool isFavorite(String spotName) {
    return getFavorites().contains(spotName);
  }

  void toggleFavorite(String spotName) {
    _ensureInit();
    final favs = getFavorites();
    if (favs.contains(spotName)) {
      favs.remove(spotName);
    } else {
      favs.add(spotName);
    }
    _prefs!.setStringList(_favKey, favs.toList());
  }

  int getFavoriteCount() => getFavorites().length;

  // ========== 清空当前用户数据（切换账号时调用） ==========

  void clearUserData() {
    _ensureInit();
    _prefs!.remove(_browseKey);
    _prefs!.remove(_uploadKey);
    _prefs!.remove(_favKey);
    _prefs!.remove(_profileNameKey);
    _prefs!.remove(_birthdayKey);
    _prefs!.remove(_bioKey);
  }

  // ========== 个人资料 ==========

  String getProfileName() {
    _ensureInit();
    return _prefs!.getString(_profileNameKey) ?? '赏花人';
  }

  void setProfileName(String name) {
    _ensureInit();
    _prefs!.setString(_profileNameKey, name.trim());
  }

  // ========== 生日 ==========

  String? getBirthday() {
    _ensureInit();
    return _prefs!.getString(_birthdayKey);
  }

  void setBirthday(String? birthday) {
    _ensureInit();
    if (birthday == null || birthday.trim().isEmpty) {
      _prefs!.remove(_birthdayKey);
    } else {
      _prefs!.setString(_birthdayKey, birthday.trim());
    }
  }

  // ========== 个性签名 ==========

  String? getBio() {
    _ensureInit();
    return _prefs!.getString(_bioKey);
  }

  void setBio(String? bio) {
    _ensureInit();
    if (bio == null || bio.trim().isEmpty) {
      _prefs!.remove(_bioKey);
    } else {
      _prefs!.setString(_bioKey, bio.trim());
    }
  }
}
