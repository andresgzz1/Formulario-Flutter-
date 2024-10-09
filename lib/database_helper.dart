// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'registro_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'registros.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Tabla de la base de datos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE registros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        correo TEXT,
        direccion TEXT,
        fechaNacimiento TEXT,
        password TEXT
      )
    ''');
  }

  // Insertar registro
  Future<int> insertRegistro(Registro registro) async {
    final db = await database;
    return await db.insert('registros', registro.toMap());
  }

  // Obtener registros
  Future<List<Registro>> getRegistros() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('registros');

    return List.generate(maps.length, (i) {
      return Registro.fromMap(maps[i]);
    });
  }

  // Boton Extra*** Eliminar un registro por ID
  Future<void> deleteRegistro(int id) async {
    final db = await database;
    await db.delete(
      'registros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
