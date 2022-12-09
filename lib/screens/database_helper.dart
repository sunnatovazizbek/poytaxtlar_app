import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/tasks_model.dart';

class DatabaseHelper{
  static final DatabaseHelper instance = DatabaseHelper._instance();

  static Database? _db;

  DatabaseHelper._instance();

  Future<Database?> get db async {
    return _db ?? await _initDB();
  }


  final String tableName = "tableTodo";

  final String colId = "id";
  final String colTitle = "title";
  final String colDescription = "description";
  final String colDate = "date";
  final String colStartTime = "startTime";
  final String colEndTime = "endTime";


  Future<Database?> _initDB() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = "${documentDirectory.path}todo.db";
    _db = await openDatabase(path, version: 1, onOpen: (db){}, onCreate: (Database db, int version) async {
      db.execute(
        "CREATE TABLE $tableName ("
            "$colId INTEGER PRIMARY KEY,"
            "$colTitle TEXT,"
            "$colDescription TEXT,"
            "$colDate TEXT,"
            "$colStartTime TEXT,"
            "$colEndTime TEXT"
      ")");
    });
    return _db;
  }

  Future<Task> insert(Task task) async {
    final data = await db;
    task.id = await data?.insert(tableName, task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return task;
  }

  Future<List<Map<String, Object?>>?> getTaskMap() async {
    final data = await db;
    final List<Map<String, Object?>>? result = await data?.query(tableName);
    return result;
  }

  Future<List<Task>> getTask() async {
    final List<Map<String, Object?>>? taskMap = await getTaskMap();
    final List<Task> tasks = [];
    taskMap?.forEach((element) {tasks.add(Task.forMap(element));});
    return tasks;
  }

  Future<int?> update(Task task) async {
    final data = await db;
    return await data?.update(tableName, task.toMap(),
      where: "$colId = ?", whereArgs: [task.id],
    );
  }

  Future<int?> delete(int id) async {
    final data = await db;
    return await data?.delete(tableName,
      where: "$colId = ?", whereArgs: [id],
    );
  }
}