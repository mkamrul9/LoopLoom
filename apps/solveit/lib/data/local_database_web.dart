import 'package:sembast_web/sembast_web.dart';

Future<Database> openPracticeDatabase() =>
    databaseFactoryWeb.openDatabase('solveit-workbook', version: 1);
