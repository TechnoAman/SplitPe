abstract class QuickPayStorage {
  // In-memory only session storage - User Profile is strictly the ONLY data that survives restarts
  static QuickPayStorage instance = InMemoryStorage();

  Future<void> saveString(String key, String value);
  Future<String?> readString(String key);
  Future<void> remove(String key);
}

class InMemoryStorage implements QuickPayStorage {
  static final Map<String, String> _mem = {};

  @override
  Future<void> saveString(String key, String value) async {
    _mem[key] = value;
  }

  @override
  Future<String?> readString(String key) async {
    return _mem[key];
  }

  @override
  Future<void> remove(String key) async {
    _mem.remove(key);
  }
}
