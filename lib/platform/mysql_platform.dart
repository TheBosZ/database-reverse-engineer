part of database_reverse_engineer;

class MysqlPlatform extends DefaultPlatform {

	MysqlPlatform([DDO con = null]) : super(con);

	String _tableEngineKeyword = 'ENGINE';
	String _defaultTableEngine = 'MyISAM';

	void initialize() {
		super.initialize();

		setSchemaDomainMapping(new Domain(PropelTypes.BOOLEAN, "TINYINT"));
		setSchemaDomainMapping(new Domain(PropelTypes.NUMERIC, "DECIMAL"));
		setSchemaDomainMapping(new Domain(PropelTypes.LONGVARCHAR, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.BINARY, "BLOB"));
		setSchemaDomainMapping(new Domain(PropelTypes.VARBINARY, "MEDIUMBLOB"));
		setSchemaDomainMapping(new Domain(PropelTypes.LONGVARBINARY, "LONGBLOB"));
		setSchemaDomainMapping(new Domain(PropelTypes.INTEGER_TIMESTAMP, "INT"));
		setSchemaDomainMapping(new Domain(PropelTypes.BLOB, "LONGBLOB"));
		setSchemaDomainMapping(new Domain(PropelTypes.CLOB, "LONGTEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.TIMESTAMP, "DATETIME"));
		setSchemaDomainMapping(new Domain(PropelTypes.OBJECT, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.DART_ARRAY, "TEXT"));
		setSchemaDomainMapping(new Domain(PropelTypes.ENUM, "TINYINT"));
	}

	void setTableEngineKeyword(String k) {
		_tableEngineKeyword = k;
	}

	String getTableEngineKeyword() => _tableEngineKeyword;

	void setDefaultTableEngine(String v) {
		_defaultTableEngine = v;
	}

	String getDefaultTableEngine() => _defaultTableEngine;

	String getAutoIncrement() => 'AUTO_INCREMENT';

	//int getMaxColumnNameLength() => 64; //Base is 64, no need to override

	bool supportsNativeDeleteTrigger() => getDefaultTableEngine().toLowerCase() == 'innodb';

	String getAddTablesDDL(Database database) {
		String ret = getBeginDDL();
		database.getTablesForSql().forEach((Table t) {
			ret = "${ret}${getCommentBlockDDL(t.getName())}";
			ret = "${ret}${getDropTableDDL(t)}";
			ret = "${ret}${getAddTableDDL(t)}";
		});
		ret = "${ret}${getEndDDL()}";
		return ret;
	}

	String getBeginDDL() => "\nSET FOREIGN_KEY_CHECKS = 0\n";

	String getEndDDL() => "\nSET FOREIGN_KEY_CHECKS = 1;\n";

	String getAddTableDDL(Table t) {
		List<String> lines = new List<String>();

		t.getColumns().forEach((Column column) {
			lines.add(getColumnDDL(column));
		});

		if (t.hasPrimaryKey()) {
			lines.add(getPrimaryKeyDDL(t));
		}

		t.getUnices().forEach((Unique unique) {
			lines.add(getUniqueDDL(unique));
		});

		t.getIndices().forEach((Index index) {
			lines.add(getIndexDDL(index));
		});

		t.getForeignKeys().forEach((ForeignKey fk) {
			if (fk.isSkipSql()) {
				return;
			}
			lines.add(getForeignKeyDDL(fk));
		});

		String mysqlTableType;
		VendorInfo vi = t.getVendorInfoForType('mysql');
		if (vi.hasParameter('Type')) {
			mysqlTableType = vi.getParameter('Type');
		} else if (vi.hasParameter('Engine')) {
			mysqlTableType = vi.getParameter('Engine');
		} else {
			mysqlTableType = getDefaultTableEngine();
		}
		List<String> tableOptions = getTableOptions(t);

		if (t.getDescription() != null) {
			tableOptions.add("COMMENT=${quote(t.getDescription())}");
		}

		String tableOptionsString = tableOptions.isNotEmpty ? " ${tableOptions.join(" ")}" : '';

		String sep = ''',
				''';
		return '''
CREATE TABLE ${quoteIdentifier(t.getName())}
(
	${lines.join(sep)}
) ${getTableEngineKeyword()}=${mysqlTableType}${tableOptionsString};
''';

	}

	List<String> getTableOptions(Table table) {
		List<String> tableOptions = new List<String>();
		VendorInfo dbVI = table.getDatabase().getVendorInfoForType('mysql');
		VendorInfo tableVI = table.getVendorInfoForType('mysql');
		VendorInfo vi = dbVI.getMergedVendorInfo(tableVI);
		const {
			'Charset': 'CHARACTER SET',
			'Collate': 'COLLATE',
			'Checksum': 'CHECKSUM',
			'Pack_Keys': 'PACK_KEYS',
			'Delay_key_write': 'DELAY_KEY_WRITE',
		}.forEach((String name, String sqlName){
			if(vi.hasParameter(name)) {
				tableOptions.add("${sqlName}=${quote(vi.getParameter(name))}");
			}
		});
		return tableOptions;
	}

	String getDropTableDDL(Table table) => "\nDROP TABLE IF EXISTS ${quoteIdentifier(table.getName())};\n";

	String getColumnDDL(Column col) {
		Domain domain = col.getDomain();
		String sqlType = domain.getSqlType();
		String notNullString = getNullString(col.isNotNull());
		String defaultSetting = getColumnDefaultValueDDL(col);

		ColumnDefaultValue def = domain.getDefaultValue();
		switch(sqlType) {
			case 'DATETIME':
				if(def != null && def.isExpression()) {
					sqlType = 'TIMESTAMP';
				}
				break;
			case 'DATE':
				if(def != null && def.isExpression()) {
					throw new Exception("DATE columns cannot have default *expressions* in MySQL");
				}
				break;
			case 'TEXT':
			case 'BLOB':
				if(def != null) {
					throw new Exception("BLOB and TEXT columns cannot have *default* values in MySQL");
				}
				break;
		}

		List<String> ddl = [quoteIdentifier(col.getName())];
		if(hasSize(sqlType)) {
			ddl.add("${sqlType}${domain.printSize()}");
		} else {
			ddl.add(sqlType);
		}

		VendorInfo colInfo = col.getVendorInfoForType(getDatabaseType());

		if(colInfo.hasParameter('Charset')) {
			ddl.add("CHARACTER SET ${quote(colInfo.getParameter('Charset'))}");
		}

		if(colInfo.hasParameter('Collation')){
			ddl.add("COLLATE ${quote(colInfo.getParameter('Collation'))}");
		} else if(colInfo.hasParameter('Collate')) {
			ddl.add("COLLATE ${quote(colInfo.getParameter('Collate'))}");
		}

		if(sqlType == 'TIMESTAMP') {
			if(notNullString.isEmpty) {
				notNullString = 'NULL';
			}

			if(defaultSetting.isEmpty && notNullString == 'NOT NULL') {
				defaultSetting = 'DEFAULT CURRENT_TIMESTAMP';
			}
			if(notNullString.isNotEmpty) {
				ddl.add(notNullString);
			}
			if(defaultSetting.isNotEmpty) {
				ddl.add(defaultSetting);
			}
		} else {
			if(defaultSetting != null && defaultSetting.isNotEmpty) {
				ddl.add(defaultSetting);
			}

			if(notNullString != null) {
				ddl.add(notNullString);
			}
		}

		String autoIncrement = col.getAutoIncrementString();
		if(autoIncrement != null && autoIncrement.isNotEmpty) {
			ddl.add(autoIncrement);
		}

		if(col.getDescription() != null) {
			ddl.add("COMMENT ${quote(col.getDescription())}");
		}
		return ddl.join(" ");
	}

	String getIndexColumnListDDL(Index index) {
		List<String> list = new List<String>();
		index.getColumns().forEach((Column c){
			list.add("${quoteIdentifier(c.getName())}${index.hasColumnSize(c.getName()) ? index.getColumnSize(c.getName()) : ''}");
		});
		return list.join(', ');
	}

	String getDropPrimaryKeyDDL(Table table) => "\nALTER TABLE ${quoteIdentifier(table.getName())} DROP PRIMARY KEY";

	String getAddIndexDDL(Index index) =>
		"\nCREATE ${getIndexType(index)}INDEX ${quoteIdentifier(index.getName())} ON ${quoteIdentifier(index.getTable().getName())} (${getColumnListDDL(index.getColumns())})\n";

	String getDropIndexDDL(Index index) =>
		"\nDROP INDEX ${quoteIdentifier(index.getName())} on ${quoteIdentifier(index.getTable().getName())}\n";

	String getIndexDDL(Index index) =>
		"${getIndexType(index)}INDEX ${quoteIdentifier(index.getName())} (${getIndexColumnListDDL(index)})";

	String getIndexType(Index index) {
		String type = '';
		VendorInfo vi = index.getVendorInfoForType(getDatabaseType());
		if(vi != null && vi.hasParameter('Index_type')) {
			type = "${vi.getParameter('Index_type')} ";
		} else if(index.isUnique()) {
			type = 'UNIQUE ';
		}
		return type;
	}

	String getUniqueDDL(Unique unique) =>
		"UNIQUE INDEX ${quoteIdentifier(unique.getName())} (${getIndexColumnListDDL(unique)})";

	String getDropForeignKeyDDL(ForeignKey fk){
		if(fk.isSkipSql()) {
			return '';
		}
		return "\nALTER TABLE ${quoteIdentifier(fk.getTable().getName())} DROP FOREIGN KEY ${fk.getName()}\n";
	}

	String getForeignKeyDDL(ForeignKey fk) {
		if(fk.isSkipSql()) {
			return '';
		}
		StringBuffer sb = new StringBuffer("CONSTRAINT ");
		sb.write(quoteIdentifier(fk.getName()));
		sb.write(" FOREIGN KEY (");
		sb.write(getColumnListDDL(fk.getLocalColumnObjects()));
		sb.write(")\nREFERENCES ");
		sb.write(quoteIdentifier(fk.getForeignTableName()));
		sb.write(" (");
		sb.write(getColumnListDDL(fk.getForeignColumnObjects()));
		sb.write(")");
		if(fk.hasOnUpdate()) {
			sb.write("\nON UPDATE ");
			sb.write(fk.getOnUpdate());
		}
		if(fk.hasOnDelete()) {
			sb.write("\nON DELETE ");
			sb.write(fk.getOnDelete());
		}
		return sb.toString();

	}

	String getCommentLineDDL(String comment) => "-- ${comment}\n";

	String getCommentBlockDDL(String comment) => '''
-- ---------------------------------------------------------------------
-- ${comment}
-- ---------------------------------------------------------------------
''';

/*
	String getModifyDatabaseDDL(PropelDatabaseDiff databaseDiff) {

	}
	*/

	String getRenameTableDDL(String fromTableName, String toTableName) =>
		"\nRENAME TABLE ${quoteIdentifier(fromTableName)} TO ${quoteIdentifier(toTableName)};\n";

	String getRemoveColumnDDL(Column column) =>
		"\nALTER TABLE ${quoteIdentifier(column.getTable().getName())} DROP ${quoteIdentifier(column.getName())}\n";

	String getRenameColumnDDL(Column from, Column to) => getChangeColumnDDL(from, to);

	String getModifyColumnDDL(PropelColumnDiff columnDiff) => getChangeColumnDDL(columnDiff.getFromColumn(), columnDiff.getToColumn());

	String getChangeColumnDDL(Column from, Column to) =>
		"\nALTER TABLE ${quoteIdentifier(from.getTable().getName())} CHANGE ${quoteIdentifier(from.getName())} ${getColumnDDL(to)};\n";

	String getModifyColumnsDDL(List<PropelColumnDiff> columnDiffs) =>
		columnDiffs.map((PropelColumnDiff cd) => getModifyColumnDDL(cd)).toList().join();

	bool supportsSchema() => true;

	bool hasSize(String sqlType) =>
		!(['MEDIUMTEXT', 'LONGTEXT', 'BLOB', 'MEDIUMBLOB', 'LONGBLOB'].contains(sqlType));

	String disconnectedEscapeText(String text) => addSlashes(text);

	String quoteIdentifier(String text) =>
		_isIdentifierQuotingEnabled ? "`${text.replaceAll(".", "`.`")}" : text;

	String getTimeStampFormatter() => 'Y-m-d H:i:s';
}
