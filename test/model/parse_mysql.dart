import 'package:database_reverse_engineer/database_reverse_engineer.dart';
import 'package:unittest/unittest.dart';
import 'package:ddo/drivers/ddo_mysql.dart';
import 'package:ddo/ddo.dart';
import 'dart:async';

main() async {
	DDOMySQL driver = new DDOMySQL('localhost', 'redstone_test', 'redstone', 'password');
	DDO conn = new DDO(driver);
	MysqlSchemaParser parser = new MysqlSchemaParser(conn);
	Database db =new Database('mysql');
	MysqlPlatform platform = new MysqlPlatform(conn);
	platform.setDefaultTableEngine('InnoDB');
	db.setPlatform(platform);
	int parseResult = await parser.parse(db);
	List<Table> tables = db.getTables();

	Table t = tables.first;
	print(tables.length);
    List columns = t.getColumns();
//	print(t.getPrimaryKey());
    print(columns.length);
    print(columns.first.getDartName());


}
