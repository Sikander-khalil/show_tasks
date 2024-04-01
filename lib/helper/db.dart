import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/task.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String taskTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colNote = 'note';
  String colDate = 'date';
  String notificationTime = 'notifyTime';
  String colColor = 'color';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    var tasksDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return tasksDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, $colNote TEXT, $colDate TEXT, $notificationTime TEXT, $colColor INTEGER)');
  }

  Future<int> insertTask(Task task) async {
    Database db = await database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  Future<List<Task>> getTasks(DateTime? date) async {
    Database db = await database;
    String query = 'SELECT * FROM $taskTable';
    List<dynamic> arguments = [];

    if (date != null) {
      query += ' WHERE $colDate = ?';
      arguments.add(DateFormat('yyyy-MM-dd').format(date));
    }

    var result = await db.rawQuery(query, arguments);
    List<Task> tasks = [];
    for (var item in result) {
      tasks.add(Task.fromMap(item));
    }
    return tasks;
  }
}
