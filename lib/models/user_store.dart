import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class AppUser {
  final String name;
  final String email;
  final String phone;
  final String password;

  AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'password': password,
  };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    name: j['name'] as String,
    email: j['email'] as String,
    phone: j['phone'] as String,
    password: j['password'] as String,
  );
}

class UserStore {
  static final _box = GetStorage();
  static const _key = 'users';           // lista JSON de usuarios
  static const _currentKey = 'currentUser'; // usuario logueado

  // Leer lista completa
  static List<AppUser> getAll() {
    final raw = _box.read<String>(_key);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(AppUser.fromJson).toList();
  }

  // Guardar lista completa
  static Future<void> _saveAll(List<AppUser> users) async {
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    await _box.write(_key, raw);
  }

  // Registrar (evita emails repetidos)
  static Future<String?> register(AppUser user) async {
    final users = getAll();
    final exists = users.any((u) => u.email.toLowerCase() == user.email.toLowerCase());
    if (exists) return 'Ya existe un usuario con ese correo';
    users.add(user);
    await _saveAll(users);
    return null; // null = ok
  }

  // Login: retorna null si ok, o mensaje de error
  static Future<String?> login(String email, String password) async {
    final users = getAll();
    final user = users.firstWhere(
          (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => AppUser(name: '', email: '', phone: '', password: ''),
    );
    if (user.email.isEmpty) return 'Usuario no encontrado';
    if (user.password != password) return 'Contraseña incorrecta';

    // Persistir sesión
    await _box.write('isLoggedIn', true);
    await _box.write(_currentKey, user.toJson());
    return null;
  }

  static Map<String, dynamic>? currentUserJson() => _box.read(_currentKey);

  static Future<void> logout() async {
    await _box.write('isLoggedIn', false);
    await _box.remove(_currentKey);
  }
}