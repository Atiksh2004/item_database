import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stock_audit_tool/src/app-config/app_config.dart';
import 'package:stock_audit_tool/src/shared/models/auditmodels.dart';
import 'package:stock_audit_tool/src/utils/resources/resources.dart';

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
          "CREATE TABLE IF NOT EXISTS StockAuditAttachments (_id INTEGER PRIMARY KEY,auditNo TEXT NOT NULL, trustReceiptNo TEXT NULL, attachment_No_ INTEGER NULL, fileExtension TEXT NULL, fileName TEXT NULL, description TEXT NULL, localFilePath TEXT NULL, assetNo TEXT NULL)");
      print("CREATE TABLE SUCCESS: StockAuditAttachments");
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> insertAudit(dynamic audit) async {
    try {
      final savedAsDraft =
          audit.savedAsDraft == null || audit.savedAsDraft == ""
              ? false
              : audit.savedAsDraft;

      const query =
          "INSERT INTO StockAudit (auditNo, dealerNo, dealerName, dealerType, auditorName, auditDate, audit_Details, auditCompleted, audit_Salesperson, status, savedAsDraft, attachement_Added, longitude, latitude, companyCode, additional_Details) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, "stockaudit.db");
      final db = await openDatabase(path);

      await db.transaction((txn) async {
        await txn.rawInsert(query, [
          audit.auditNo,
          audit.dealerNo,
          audit.dealerName,
          audit.dealerType,
          audit.auditorName,
          audit.auditDate,
          audit.auditDetails,
          audit.auditCompleted,
          audit.auditSalesperson,
          audit.status,
          savedAsDraft,
          audit.attachementAdded,
          audit.longitude,
          audit.latitude,
          audit.companyCode,
          audit.additionalDetails,
        ]);
      });

      await db.close();
      print("INSERT AUDIT: SUCCESS");
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<bool> insertAuditTrail(auditTrail) async {
    String query =
        "INSERT INTO StockAuditTrail (auditNo, trustReceiptNo, assetNo, description) VALUES (?, ?, ?, ?)";
    try {
      Database db = await openDatabase('stockaudit.db');
      int result = await db.rawInsert(query, [
        auditTrail.auditNo,
        auditTrail.trustReceiptNo,
        auditTrail.assetNo,
        auditTrail.description,
      ]);
      print("INSERT AUDIT TRAIL $result");
      if (result != 0) {
        return true;
      } else {
        throw false;
      }
    } catch (error) {
      print("INSERT AUDIT TRAIL ERROR $error");
      throw false;
    }
  }

  Future<bool> updateAudit(audit) async {
    print(audit);
    String query =
        "UPDATE StockAudit SET audit_Details = ?, auditCompleted = ?, audit_Salesperson = ?, status = ?, savedAsDraft = ?, longitude = ?, latitude = ? , additional_Details = ? WHERE auditNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      int result = await db.rawUpdate(query, [
        audit.audit_Details,
        audit.auditCompleted,
        audit.audit_Salesperson,
        audit.status,
        audit.savedAsDraft,
        audit.longitude,
        audit.latitude,
        audit.additional_Details,
        audit.auditNo,
      ]);
      print("UPDATE AUDIT $result");
      if (result != 0) {
        return true;
      } else {
        throw false;
      }
    } catch (error) {
      print("UPDATE AUDIT ERROR $error");
      throw false;
    }
  }

  Future<void> insertAuditAssets(List<AuditAssetDetails>? auditAssets) async {
    String query =
        "INSERT INTO StockAuditAssets (auditNo, trustReceiptNo, lineNo, assetNo, soldDate, soldTo, mileageHours, invoiceNo, stockAuditStatus, serialNo, vin, status, statusCode, ffpCode, kilometer, notes, newUsed, makeModel, dif, diF_Date, insurance___3M, open_Receivable, insurance_End_Date, isAdditionalAsset, engineNo, asset_Description, modelYear, colour, dealerNo, dealerName, hin, outboard_SerialNo, modelCode, wave_RunnerID, unitCondition, date_Dealer_Paid, isDemo, isYMA, actioned, termination_Code, registration) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    for (var auditAsset in auditAssets!) {
      bool isAdditionalAsset = false;
      if (auditAsset.isAdditionalAsset != null) {
        isAdditionalAsset = auditAsset.isAdditionalAsset!;
        if (isAdditionalAsset) {
          auditAsset.isDemo = false;
          auditAsset.isYMA = false;
          auditAsset.dif = false;
          auditAsset.diF_Date = null;
          auditAsset.insurance___3M = false;
          auditAsset.open_Receivable = false;
          auditAsset.insurance_End_Date = null;
        }
      }
      try {
        Database db = await openDatabase('stockaudit.db');
        int result = await db.rawInsert(query, [
          auditAsset.auditNo,
          auditAsset.trustReceiptNo,
          auditAsset.lineNo,
          auditAsset.assetNo,
          auditAsset.soldDate,
          auditAsset.soldTo,
          auditAsset.mileageHours,
          auditAsset.invoiceNo,
          auditAsset.stockAuditStatus,
          auditAsset.serialNo,
          auditAsset.vin,
          auditAsset.status,
          auditAsset.statusCode,
          auditAsset.ffpCode,
          auditAsset.kilometer,
          auditAsset.notes,
          auditAsset.newUsed,
          auditAsset.makeModel,
          auditAsset.dif,
          auditAsset.diF_Date,
          auditAsset.insurance___3M,
          auditAsset.open_Receivable,
          auditAsset.insurance_End_Date,
          isAdditionalAsset,
          auditAsset.engineNo,
          auditAsset.asset_Description,
          auditAsset.modelYear,
          auditAsset.colour,
          auditAsset.dealerNo,
          auditAsset.dealerName,
          auditAsset.hin,
          auditAsset.outboard_SerialNo,
          auditAsset.modelCode,
          auditAsset.wave_RunnerID,
          auditAsset.unitCondition,
          auditAsset.date_Dealer_Paid,
          auditAsset.isDemo,
          auditAsset.isYMA,
          auditAsset.actioned,
          auditAsset.termination_Code,
          auditAsset.registration,
        ]);
        print("INSERT AUDIT ASSETS $result");
      } catch (error) {
        print("INSERT AUDIT ASSETS ERROR $error");
      }
    }
  }

  Future<bool> insertAuditAsset(AuditAssetDetails auditAsset) async {
    String query =
        "INSERT INTO StockAuditAssets (auditNo, trustReceiptNo, lineNo, assetNo, soldDate, soldTo, mileageHours, invoiceNo, stockAuditStatus, serialNo, vin, status, statusCode, ffpCode, kilometer, notes, newUsed, makeModel, dif, diF_Date, insurance___3M, open_Receivable, insurance_End_Date, isAdditionalAsset, engineNo, asset_Description, modelYear, colour, dealerNo, dealerName, hin, outboard_SerialNo, modelCode, wave_RunnerID, unitCondition, date_Dealer_Paid, isDemo, isYMA, actioned, termination_Code, registration) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    if (auditAsset.isAdditionalAsset != null) {
      auditAsset.isDemo = false;
      auditAsset.isYMA = false;
      auditAsset.actioned = true;
      auditAsset.dif = false;
      auditAsset.insurance___3M = false;
      auditAsset.open_Receivable = false;
    }
    try {
      Database db = await openDatabase('stockaudit.db');
      int result = await db.rawInsert(query, [
        auditAsset.auditNo,
        auditAsset.trustReceiptNo,
        auditAsset.lineNo,
        auditAsset.assetNo,
        auditAsset.soldDate,
        auditAsset.soldTo,
        auditAsset.mileageHours,
        auditAsset.invoiceNo,
        auditAsset.stockAuditStatus,
        auditAsset.serialNo,
        auditAsset.vin,
        auditAsset.status,
        auditAsset.statusCode,
        auditAsset.ffpCode,
        auditAsset.kilometer,
        auditAsset.notes,
        auditAsset.newUsed,
        auditAsset.makeModel,
        auditAsset.dif,
        auditAsset.diF_Date,
        auditAsset.insurance___3M,
        auditAsset.open_Receivable,
        auditAsset.insurance_End_Date,
        auditAsset.isAdditionalAsset,
        auditAsset.engineNo,
        auditAsset.asset_Description,
        auditAsset.modelYear,
        auditAsset.colour,
        auditAsset.dealerNo,
        auditAsset.dealerName,
        auditAsset.hin,
        auditAsset.outboard_SerialNo,
        auditAsset.modelCode,
        auditAsset.wave_RunnerID,
        auditAsset.unitCondition,
        auditAsset.date_Dealer_Paid,
        auditAsset.isDemo,
        auditAsset.isYMA,
        auditAsset.actioned,
        auditAsset.termination_Code,
        auditAsset.registration,
      ]);
      print("INSERT AUDIT ASSET $result");
      if (result != 0) {
        return true;
      } else {
        throw false;
      }
    } catch (error) {
      print("INSERT AUDIT ASSET ERROR $error");
      throw false;
    }
  }

  Future<bool> updateAuditAsset(auditAsset) async {
    print("${auditAsset.auditNo} ${auditAsset.registration}");
    String query =
        "UPDATE StockAuditAssets SET soldDate = ?, soldTo = ?, mileageHours = ?, stockAuditStatus = ?, status = ?, statusCode = ?, kilometer = ?, notes = ?, isAdditionalAsset = ?, unitCondition = ?, date_Dealer_Paid = ?, isDemo = ?, actioned = ?, termination_Code = ?, registration = ? WHERE auditNo = ? AND trustReceiptNo = ? AND lineNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      int result = await db.rawUpdate(query, [
        auditAsset.soldDate,
        auditAsset.soldTo,
        auditAsset.mileageHours,
        auditAsset.stockAuditStatus,
        auditAsset.status,
        auditAsset.statusCode,
        auditAsset.kilometer,
        auditAsset.notes,
        auditAsset.isAdditionalAsset,
        auditAsset.unitCondition,
        auditAsset.date_Dealer_Paid,
        auditAsset.isDemo,
        auditAsset.actioned,
        auditAsset.termination_Code,
        auditAsset.registration,
        auditAsset.auditNo,
        auditAsset.trustReceiptNo,
        auditAsset.lineNo,
      ]);
      print("UPDATE AUDIT ASSET $result");
      if (result != 0) {
        return true;
      } else {
        throw false;
      }
    } catch (error) {
      print("UPDATE AUDIT ASSET ERROR $error");
      throw false;
    }
  }

  Future<bool> updateAdditionalAuditAsset(auditAsset) async {
    String query =
        "UPDATE StockAuditAssets SET assetNo = ?, makeModel = ?, vin = ?, engineNo = ?, hin = ?, outboard_SerialNo = ?, modelCode = ?, wave_RunnerID = ?, serialNo = ?, notes = ?, registration = ? , mileageHours = ? WHERE auditNo = ? AND trustReceiptNo = ? AND lineNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      int result = await db.rawUpdate(query, [
        auditAsset['assetNo'],
        auditAsset['makeModel'],
        auditAsset['vin'],
        auditAsset['engineNo'],
        auditAsset['hin'],
        auditAsset['outboard_SerialNo'],
        auditAsset['modelCode'],
        auditAsset['wave_RunnerID'],
        auditAsset['serialNo'],
        auditAsset['notes'],
        auditAsset['registration'],
        auditAsset['mileage'],
        auditAsset['auditNo'],
        auditAsset['trustReceiptNo'],
        auditAsset['lineNo'],
      ]);
      print("UPDATE ADDITIONAL ASSET $result");
      if (result != 0) {
        return true;
      } else {
        throw false;
      }
    } catch (error) {
      print("UPDATE ADDITIONAL ASSET ERROR $error");
      throw false;
    }
  }

  Future<bool> deleteAuditAsset(AuditAssetDetails auditAsset) async {
    String query =
        "DELETE FROM StockAuditAssets WHERE auditNo = ? AND trustReceiptNo = ? AND lineNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      int result = await db.rawDelete(query, [
        auditAsset.auditNo,
        auditAsset.trustReceiptNo,
        auditAsset.lineNo,
      ]);
      print("DELETE AUDIT ASSET $result");
      if (result != 0) {
        return true;
      } else {
        throw false;
      }
    } catch (error) {
      print("DELETE AUDIT ASSET ERROR $error");
      throw false;
    }
  }

  Future<bool> deleteAudit(auditNo) async {
    String query1 = "DELETE FROM StockAudit WHERE auditNo = ?";
    String query2 = "DELETE FROM StockAuditAssets WHERE auditNo = ?";
    String query3 = "DELETE FROM StockAuditTrail WHERE auditNo = ?";
    String query4 = "DELETE FROM StockAuditAttachments WHERE auditNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      await db.transaction((txn) async {
        await txn.rawDelete(query1, [auditNo]);
        await txn.rawDelete(query2, [auditNo]);
        await txn.rawDelete(query3, [auditNo]);
        await txn.rawDelete(query4, [auditNo]);
      });
      print("DELETE AUDIT");
      return true;
    } catch (error) {
      print("DELETE AUDIT ERROR $error");
      throw error;
    }
  }

  Future<bool> isAuditSaved(auditNo) async {
    String query = "SELECT * FROM StockAudit WHERE auditNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      List<Map<String, dynamic>> result = await db.rawQuery(query, [auditNo]);
      return result.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  Future<String> getAudit(String auditNo) async {
    String query = "SELECT * FROM StockAudit WHERE auditNo = ?";
    try {
      Database db = await openDatabase('stockaudit.db');
      List<Map<String, dynamic>> result = await db.rawQuery(query, [auditNo]);
      Map<String, dynamic> savedAudit = {};
      result.forEach((audit) {
        savedAudit = {
          'auditNo': audit['auditNo'],
          'dealerNo': audit['dealerNo'],
          'dealerName': audit['dealerName'],
          'dealerType': audit['dealerType'],
          'auditorName': audit['auditorName'],
          'auditDate': audit['auditDate'],
          'audit_Details': audit['audit_Details'],
          'auditCompleted': audit['auditCompleted'],
          'audit_Salesperson': audit['audit_Salesperson'],
          'status': audit['status'],
          'savedAsDraft': audit['savedAsDraft'],
          'attachement_Added': audit['attachement_Added'],
          'longitude': audit['longitude'],
          'latitude': audit['latitude'],
          'companyCode': audit['companyCode'],
          'additional_Details': audit['additional_Details'],
        };
      });
      return jsonEncode(savedAudit);
    } catch (error) {
      print("SELECT AUDIT ERROR $error");
      throw error;
    }
  }

  Future<String> getAuditList(String username, String company) async {
    List<AuditData> savedAudits = [];
    String query =
        "SELECT SA.auditNo, SA.status, SA.savedAsDraft, SA.dealerNo, SA.dealerName, SA.dealerType, COUNT(DISTINCT CASE WHEN STA.trustReceiptNo = 'N.A.' THEN STA.trustReceiptNo || '-' || STA.assetNo ELSE STA.trustReceiptNo END ) FROM StockAudit AS SA INNER JOIN StockAuditAssets AS STA ON SA.auditNo = STA.auditNo WHERE SA.status = 0 and SA.auditorName = ? and SA.companyCode = ? GROUP BY SA.auditNo, SA.status,SA.savedAsDraft, SA.dealerNo, SA.dealerName, SA.dealerType";
    try {
      Database db = await openDatabase('stockaudit.db');
      List<Map<String, dynamic>> result =
          await db.rawQuery(query, [username, company]);
      print(result);
      result.forEach((audit) {
        if (audit['auditNo'] != null) {
          AuditData auditData = AuditData(
            auditNumber: audit['auditNo'],
            dealerName: audit['dealerName'],
            dealerNo: audit['dealerNo'],
            dealerType: audit['dealerType'],
            assetCount: audit[
                "COUNT(DISTINCT CASE WHEN STA.trustReceiptNo = 'N.A.' THEN STA.trustReceiptNo || '-' || STA.assetNo ELSE STA.trustReceiptNo END )"],
            statusDesc: statusDescFromId[audit['status']],
            savedAsDraft:
                audit['savedAsDraft'] != null && audit['savedAsDraft'] != null
                    ? audit['savedAsDraft'] == 'true'
                    : false,
          );
          savedAudits.add(auditData);
        }
      });
      print("the saved json audits are - ${savedAudits}");
      return jsonEncode(savedAudits);
    } catch (error) {
      print("SELECT AUDIT ERROR $error");
      throw error;
    }
  }

  Future<String> getDealerAuditList(String dealerNo) async {
    List<Map<String, dynamic>> savedAudits = [];
    String query =
        "SELECT SA.auditNo, SA.status, SA.savedAsDraft, SA.dealerNo, SA.dealerName, SA.dealerType, COUNT(STA.auditNo) FROM StockAudit AS SA INNER JOIN StockAuditAssets AS STA ON SA.auditNo = STA.auditNo WHERE SA.status = 0 and SA.dealerNo = ? GROUP BY SA.auditNo, SA.status, SA.savedAsDraft, SA.dealerNo, SA.dealerName, SA.dealerType";
    try {
      Database db = await openDatabase('stockaudit.db');
      List<Map<String, dynamic>> result = await db.rawQuery(query, [dealerNo]);
      result.forEach((audit) {
        if (audit['auditNo'] != null) {
          savedAudits.add({
            'auditNumber': audit['auditNo'],
            'status': audit['status'],
            'savedAsDraft':
                audit['savedAsDraft'] != null && audit['savedAsDraft'] != null
                    ? audit['savedAsDraft'].toLowerCase() == 'true'
                    : false,
            'dealerNo': audit['dealerNo'],
            'dealerName': audit['dealerName'],
            'dealerType': audit['dealerType'],
            'assetCount': audit['COUNT(STA.auditNo)'],
          });
        }
      });
      return jsonEncode(savedAudits);
    } catch (error) {
      print("SELECT AUDIT ERROR $error");
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getAuditHistory(
      String username, String company) async {
    List<Map<String, dynamic>> savedAudits = [];
    try {
      Database db = await openDatabase('stockaudit.db');
      String query =
          "SELECT SA.auditNo, SA.status, SA.auditCompleted, SA.dealerNo, SA.dealerName, SA.dealerType, COUNT(STA.auditNo) FROM StockAudit AS SA INNER JOIN StockAuditAssets AS STA ON SA.auditNo = STA.auditNo WHERE SA.status = 1 and SA.auditorName = ? and SA.companyCode = ? GROUP BY SA.auditNo, SA.status, SA.dealerNo, SA.dealerName, SA.dealerType, SA.auditCompleted ORDER BY SA.auditCompleted DESC";
      List<Map<String, dynamic>> result =
          await db.rawQuery(query, [username, company]);
      result.forEach((audit) {
        if (audit['auditNo'] != null) {
          savedAudits.add({
            'auditNumber': audit['auditNo'],
            'status': audit['status'],
            'audit_Completed': audit['auditCompleted'],
            'dealerNo': audit['dealerNo'],
            'dealerName': audit['dealerName'],
            'dealerType': audit['dealerType'],
            'assetCount': audit['COUNT(STA.auditNo)'],
          });
        }
      });
      return savedAudits;
    } catch (error) {
      print("SELECT AUDIT ERROR $error");
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getDealerAuditHistory(
      String dealerNo) async {
    List<Map<String, dynamic>> savedAudits = [];
    try {
      Database db = await openDatabase('stockaudit.db');
      String query =
          "SELECT SA.auditNo, SA.status, SA.auditCompleted, SA.dealerNo, SA.dealerName, SA.dealerType, COUNT(STA.auditNo) FROM StockAudit AS SA INNER JOIN StockAuditAssets AS STA ON SA.auditNo = STA.auditNo WHERE SA.status = 1 and SA.dealerNo = ? GROUP BY SA.auditNo, SA.status, SA.dealerNo, SA.dealerName, SA.dealerType, SA.auditCompleted";
      List<Map<String, dynamic>> result = await db.rawQuery(query, [dealerNo]);
      result.forEach((audit) {
        if (audit['auditNo'] != null) {
          savedAudits.add({
            'auditNumber': audit['auditNo'],
            'status': audit['status'],
            'audit_Completed': audit['auditCompleted'],
            'dealerNo': audit['dealerNo'],
            'dealerName': audit['dealerName'],
            'dealerType': audit['dealerType'],
            'assetCount': audit['COUNT(STA.auditNo)'],
          });
        }
      });
      return savedAudits;
    } catch (error) {
      print("SELECT AUDIT ERROR $error");
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getAuditAssets(String auditNo) async {
    List<Map<String, dynamic>> savedAuditAssets = [];
    try {
      print("here 1");
      Database db = await openDatabase('stockaudit.db');
      String query =
          "SELECT * FROM StockAuditAssets WHERE auditNo = ? ORDER BY makeModel";
      List<Map<String, dynamic>> result = await db.rawQuery(query, [auditNo]);
      result.forEach((auditAsset) {
        savedAuditAssets.add({
          'auditNo': auditAsset['auditNo'],
          'trustReceiptNo': auditAsset['trustReceiptNo'],
          'lineNo': auditAsset['lineNo'],
          'assetNo': auditAsset['assetNo'],
          'soldDate': auditAsset['soldDate'],
          'soldTo': auditAsset['soldTo'],
          'mileageHours': auditAsset['mileageHours'],
          'invoiceNo': auditAsset['invoiceNo'],
          'stockAuditStatus': auditAsset['stockAuditStatus'],
          'serialNo': auditAsset['serialNo'],
          'vin': auditAsset['vin'],
          'status': auditAsset['status'],
          'statusCode': auditAsset['statusCode'],
          'ffpCode': auditAsset['ffpCode'],
          'kilometer': auditAsset['kilometer'],
          'notes': auditAsset['notes'],
          'newUsed': auditAsset['newUsed'],
          'makeModel': auditAsset['makeModel'],
          'dif': auditAsset['dif'] != null && auditAsset['dif'] == "true",
          'diF_Date': auditAsset['diF_Date'],
          'insurance___3M': auditAsset['insurance___3M'] != null &&
              auditAsset['insurance___3M'] == "true",
          'open_Receivable': auditAsset['open_Receivable'] != null &&
              auditAsset['open_Receivable'] == "true",
          'insurance_End_Date': auditAsset['insurance_End_Date'],
          'isAdditionalAsset': auditAsset['isAdditionalAsset'] != null &&
              auditAsset['isAdditionalAsset'] == "true",
          'engineNo': auditAsset['engineNo'],
          'asset_Description': auditAsset['asset_Description'],
          'modelYear': auditAsset['modelYear'],
          'colour': auditAsset['colour'],
          'dealerNo': auditAsset['dealerNo'],
          'dealerName': auditAsset['dealerName'],
          'hin': auditAsset['hin'],
          'outboard_SerialNo': auditAsset['outboard_SerialNo'],
          'modelCode': auditAsset['modelCode'],
          'wave_RunnerID': auditAsset['wave_RunnerID'],
          'unitCondition': auditAsset['unitCondition'],
          'date_Dealer_Paid': auditAsset['date_Dealer_Paid'],
          'isDemo':
              auditAsset['isDemo'] != null && auditAsset['isDemo'] == "true",
          'isYMA': auditAsset['isYMA'] != null && auditAsset['isYMA'] == "true",
          'actioned':
              auditAsset['actioned'] != null && auditAsset['actioned'] == 1,
          'termination_Code': auditAsset['termination_Code'],
          'registration': auditAsset['registration'],
        });
        print("here 2");
      });
      return savedAuditAssets;
    } catch (error) {
      print("SELECT AUDIT ASSETS ERROR $error");
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> getAuditTrail(String auditNo) async {
    List<Map<String, dynamic>> savedAuditTrail = [];
    try {
      Database db = await openDatabase('stockaudit.db');
      String query = "SELECT * FROM StockAuditTrail WHERE auditNo = ?";
      List<Map<String, dynamic>> result = await db.rawQuery(query, [auditNo]);
      result.forEach((auditTrail) {
        savedAuditTrail.add({
          'auditNo': auditTrail['auditNo'],
          'trustReceiptNo': auditTrail['trustReceiptNo'],
          'date_TimeStamp': auditTrail['date_TimeStamp'],
          'assetNo': auditTrail['assetNo'],
          'description': auditTrail['description'],
        });
      });
      return savedAuditTrail;
    } catch (error) {
      print("SELECT AUDIT ASSETS ERROR $error");
      throw error;
    }
  }

  Future<List<AuditStatusDetails>?> getAuditCount(
      String username, String company) async {
    List<AuditStatusDetails> statusCount = [];
    final query1 = {
      'query':
          'SELECT IFNULL(COUNT(*),0) FROM StockAudit WHERE auditorName = ? and companyCode = ? and status = 0 and savedAsDraft != ?',
      'params': [username, company, "true"],
    };
    final query2 = {
      'query':
          'SELECT IFNULL(COUNT(*),0) FROM StockAudit WHERE auditorName = ? and companyCode = ? and status = 1',
      'params': [username, company],
    };
    final query3 = {
      'query':
          'SELECT IFNULL(COUNT(*),0) FROM StockAudit WHERE auditorName = ? and companyCode = ? and status = 0 and savedAsDraft = ?',
      'params': [username, company, "true"],
    };
    final queryArr = [query1, query2, query3];

    for (int i = 0; i < queryArr.length; i++) {
      print("in $i");
      try {
        final db = await openDatabase('stockaudit.db');
        final result = await db.rawQuery(queryArr[i]['query'] as String,
            queryArr[i]['params'] as List<Object?>?);
        String statusDesc = '';
        if (i == 0) {
          statusDesc = 'Pending';
        } else if (i == 2) {
          statusDesc = 'Saved As Draft';
        } else if (i == 1) {
          statusDesc = 'Completed';
        }
        print(result);
        statusCount.add(AuditStatusDetails(
            status: statusDesc,
            count: int.parse(result[0]['IFNULL(COUNT(*),0)'].toString())));
        if (i == queryArr.length - 1) {
          return statusCount;
        }
      } catch (error) {
        print('SELECT AUDIT STATUS COUNT ERROR $error');
        throw error;
      }
    }
  }

  void insertAuditAttachment(auditAttachment) async {
    final query =
        'INSERT INTO StockAuditAttachments (auditNo, trustReceiptNo, attachment_No_, fileExtension, fileName, description, localFilePath, assetNo) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
    try {
      final db = await openDatabase('stockaudit.db');
      await db.transaction((txn) async {
        final batch = txn.batch();
        batch.rawInsert(
          query,
          [
            auditAttachment.auditNo,
            auditAttachment.trustReceiptNo,
            auditAttachment.attachment_No_,
            auditAttachment.fileExtension,
            auditAttachment.fileName,
            auditAttachment.description,
            auditAttachment.localFilePath,
            auditAttachment.assetNo,
          ],
        );
        await batch.commit();
      });
      print('INSERT AUDIT ATTACHMENT');
    } catch (error) {
      print('INSERT AUDIT ATTACHMENT ERROR $error');
      throw error;
    }
  }

  Future<dynamic> getAuditAttachments(String auditNo, String assetNo) async {
    final query =
        'SELECT * FROM StockAuditAttachments WHERE auditNo = ? AND assetNo = ?';
    final List<Map<String, dynamic>> auditAttachments = [];
    try {
      final db = await openDatabase('stockaudit.db');
      final result = await db.rawQuery(query, [auditNo, assetNo]);
      result.forEach((auditAttachment) {
        auditAttachments.add({
          'id': auditAttachment['id'],
          'auditNo': auditAttachment['auditNo'],
          'trustReceiptNo': auditAttachment['trustReceiptNo'],
          'attachment_No_': auditAttachment['attachment_No_'],
          'fileExtension': auditAttachment['fileExtension'],
          'fileName': auditAttachment['fileName'],
          'description': auditAttachment['description'],
          'localFilePath': auditAttachment['localFilePath'],
          'assetNo': auditAttachment['assetNo'],
        });
      });
      return json.encode(auditAttachments);
    } catch (error) {
      print('SELECT AUDIT ATTACHMENTS ERROR $error');
      throw error;
    }
  }

  Future<dynamic> deleteAuditAttachments(
      String auditNo, String assetNo, dynamic id) async {
    final query =
        'DELETE FROM StockAuditAttachments WHERE auditNo = ? AND assetNo = ? AND _id = ?';
    try {
      final db = await openDatabase('stockaudit.db');
      await db.rawDelete(query, [auditNo, assetNo, id]);
      print('DELETE AUDIT ATTACHMENT');
      return true;
    } catch (error) {
      print('DELETE AUDIT ATTACHMENTS ERROR $error');
      throw error;
    }
  }

  Future<dynamic> getAllAuditAttachments(String auditNo) async {
    final query = 'SELECT * FROM StockAuditAttachments WHERE auditNo = ?';
    final List<Map<String, dynamic>> auditAttachments = [];
    try {
      final db = await openDatabase('stockaudit.db');
      final result = await db.rawQuery(query, [auditNo]);
      result.forEach((auditAttachment) {
        auditAttachments.add({
          'id': auditAttachment['id'],
          'auditNo': auditAttachment['auditNo'],
          'trustReceiptNo': auditAttachment['trustReceiptNo'],
          'attachment_No_': auditAttachment['attachment_No_'],
          'fileExtension': auditAttachment['fileExtension'],
          'fileName': auditAttachment['fileName'],
          'description': auditAttachment['description'],
          'localFilePath': auditAttachment['localFilePath'],
          'assetNo': auditAttachment['assetNo'],
        });
      });
      return json.encode(auditAttachments);
    } catch (error) {
      print('SELECT AUDIT ATTACHMENTS ERROR $error');
      throw error;
    }
  }

  Future<bool> createLog(String component, String msg) async {
    final query = 'INSERT INTO StockAuditAssets (component, msg) VALUES (?,?)';
    try {
      final db = await openDatabase('stockaudit.db');
      await db.rawInsert(query, [component, msg]);
      print('INSERT LOG');
      return true;
    } catch (error) {
      print('INSERT LOG ERROR $error');
      throw error;
    }
  }

  void closeDatabase() async {
    try {
      final db = await openDatabase('stockaudit.db');
      db.close();
    } catch (e) {
      print("An Error occurred closing database: $e");
    }
  }
}

class ColorList {
  get statusColors => null;
}
