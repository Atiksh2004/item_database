import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseServices {
  static final DatabaseServices _singleton = DatabaseServices._internal();

  factory DatabaseServices() {
    return _singleton;
  }

  DatabaseServices._internal();

  Database? database;
  late List<String> colors;

  List<String> statusDescFromId = [
    "Pending",
  ];

  Future<void> initializeDatabase() async {
    //colors = UIResources.statusColors;
    try {
      final exists = await databaseExists("stockaudit.db");
      if (!exists) {
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, "stockaudit.db");

        database = await openDatabase(path, version: 1,
            onCreate: (Database db, int version) async {
          print("CREATE DATABASE: SUCCESS");
          await _createTables(db);
        });
      } else {
        print("CREATE DATABASE: ALREADY PRESENT");
        await _callDB();
      }
    } catch (e) {
      print("Error in initializing database: $e");
    }
  }

  Future<void> insertItem(String itemName, double itemPrice) async {
    try {
      Database? db = await getdbconnection();
      if (db == null) {
        print("Database not available");
        return;
      }

      Map<String, dynamic> itemData = {
        'itemName': itemName,
        'itemPrice': itemPrice,
      };

      await db.insert('Dealers', itemData,
          conflictAlgorithm: ConflictAlgorithm.replace);

      print("Item inserted successfully");
    } catch (e) {
      print("Error inserting item: $e");
    }
  }

  void insertAuditAttachment(itemName, itemPrice) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "stockaudit.db");
    final db = await openDatabase(path);
    final query = 'INSERT INTO Dealers (itemName, itemPrice) VALUES (?, ?)';
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "stockaudit.db");
      final db = await openDatabase(path);

      await db.transaction((txn) async {
        await txn.rawInsert(query, [itemName, itemPrice]);
      });
      await db.close();
      print("INSERT AUDIT: SUCCESS");

      print('INSERT AUDIT ATTACHMENT');
    } catch (error) {
      print('INSERT AUDIT ATTACHMENT ERROR $error');
      throw error;
    }
  }

  Future<void> _callDB() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "stockaudit.db");
      database = await openDatabase(path);
      print(
          "Are we open yet (Callback based)? ${database != null ? 'Yes' : 'No'}");
      print("oooooooo $database");
    } catch (e) {
      print("Error calling databse: $e");
    }
  }

  Future<Database?> getdbconnection() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "stockaudit.db");
      return await openDatabase(path);
    } catch (e) {
      print("Error getting db connection: $e");
      return null;
    }
  }

  Future<void> clearDatabase() async {
    try {
      final exists = await databaseExists("stockaudit.db");
      if (exists) {
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, "stockaudit.db");

        database = await openDatabase(path, version: 1);
        await _deleteTables(database!);
        await _createTables(database!);
      } else {
        print("DATABASE REINITIALIZATION: ALREADY PRESENT");
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, "stockaudit.db");

        database =
            await openDatabase(path, version: 1, onOpen: (Database db) async {
          await _deleteTables(db);
          await _createTables(db);
        });
      }
    } catch (e) {
      print("Error clearing databases $e");
    }
  }

  Future<void> _deleteTables(Database db) async {
    try {
      await db.execute("DROP TABLE IF EXISTS StockAudit");
      print("DELETE TABLE SUCCESS: StockAudit");

      await db.execute("DROP TABLE IF EXISTS StockAuditAssets");
      print("DELETE TABLE SUCCESS: StockAuditAssets");

      await db.execute("DROP TABLE IF EXISTS StockAuditTrail");
      print("DELETE TABLE SUCCESS: StockAuditTrail");

      await db.execute("DROP TABLE IF EXISTS StockAuditAttachments");
      print("DELETE TABLE SUCCESS: StockAuditAttachments");
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> _createTables(Database db) async {
    try {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS StockAudit (auditNo TEXT PRIMARY KEY NOT NULL, dealerNo TEXT NOT NULL, dealerName TEXT NOT NULL, dealerType TEXT NOT NULL, auditorName TEXT NOT NULL, auditDate TEXT NOT NULL, audit_Details TEXT NULL, auditCompleted TEXT NULL, audit_Salesperson TEXT NULL, status INTEGER NULL, savedAsDraft INTEGER NULL, attachement_Added INTEGER NULL, longitude REAL NULL, latitude REAL NULL, companyCode TEXT NULL, additional_Details TEXT NULL)");
      print("CREATE TABLE SUCCESS: StockAudit");

      await db.execute(
          "CREATE TABLE IF NOT EXISTS StockAuditAssets(auditNo TEXT NOT NULL, trustReceiptNo TEXT NOT NULL, lineNo INTEGER NOT NULL, assetNo TEXT NULL, soldDate TEXT NULL, soldTo TEXT NULL, mileageHours INTEGER NULL, invoiceNo TEXT NULL, stockAuditStatus INTEGER NOT NULL, serialNo TEXT NULL, vin TEXT NOT NULL, status INTEGER NOT NULL, statusCode TEXT NULL, ffpCode TEXT NULL, kilometer REAL NULL, notes TEXT NULL, newUsed TEXT NULL, makeModel TEXT NULL, dif INTEGER NULL, diF_Date TEXT  NULL, insurance___3M INTEGER NULL, open_Receivable INTEGER NULL, insurance_End_Date TEXT NULL, isAdditionalAsset INTEGER NULL, engineNo TEXT NULL, asset_Description TEXT NULL, modelYear INTEGER NULL, colour TEXT NULL, dealerNo TEXT NULL, dealerName TEXT NULL, hin TEXT NULL, outboard_SerialNo TEXT NULL, modelCode TEXT NULL, wave_RunnerID TEXT NULL, unitCondition TEXT NULL, date_Dealer_Paid TEXT NULL, isDemo INTEGER NULL, isYMA INTEGER NULL, actioned INTEGER NULL, termination_Code TEXT NULL, registration TEXT NULL,PRIMARY KEY (auditNo ASC, trustReceiptNo ASC, lineNo ASC))");
      print("CREATE TABLE SUCCESS: StockAuditAssets");

      await db.execute(
          "CREATE TABLE IF NOT EXISTS StockAuditTrail (_id INTEGER PRIMARY KEY,auditNo TEXT NOT NULL, trustReceiptNo TEXT NULL, assetNo TEXT NULL, date_TimeStamp TEXT DEFAULT CURRENT_TIMESTAMP NULL, description TEXT NULL)");
      print("CREATE TABLE SUCCESS: StockAuditTrail");

      await db.execute(
          "CREATE TABLE IF NOT EXISTS Dealers (itemName TEXT PRIMARY KEY NOT NULL, itemPrice INTEGER NOT NULL");
      print("CREATE TABLE SUCCESS: StockAudit");
      await db.execute(
          "CREATE TABLE IF NOT EXISTS StockAuditAttachments (_id INTEGER PRIMARY KEY,auditNo TEXT NOT NULL, trustReceiptNo TEXT NULL, attachment_No_ INTEGER NULL, fileExtension TEXT NULL, fileName TEXT NULL, description TEXT NULL, localFilePath TEXT NULL, assetNo TEXT NULL)");
      print("CREATE TABLE SUCCESS: StockAuditAttachments");
    } catch (e) {
      print("Error occurred: $e");
    }
  }
}
