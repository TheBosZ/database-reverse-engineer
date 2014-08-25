part of database_reverse_engineer;

class DefaultPlatform implements PropelPlatformInterface {

	Map<String, Domain> _schemaDomainMap;

	DDO _con;

	bool _isIdentifierQuotingEnabled = true;

	//GeneratorConfig _generatorConfig;

	DefaultPlatform([DDO this._con = null]) {
		initialize();
	}

	void setConnection([DDO con = null]) {
		_con = con;
	}

	@override
	DDO getConnection() => _con;

	/*void setGeneratorConfig(GeneratorConfig config) {

	}*/

	Object getBuildProperty(String name) {
		//if(_generatorConfig != null) {
		//return _generatorConfig.getBuildProperty(name);
		//}
		return null;
	}

	void initialize() {
		_schemaDomainMap = new Map<String, Domain>();
		for(String t in PropelTypes.getPropelTypes()) {
			_schemaDomainMap[t] = new Domain(t);
		}

		_schemaDomainMap[PropelTypes.BU_DATE] = new Domain(PropelTypes.DATE);
		_schemaDomainMap[PropelTypes.BU_TIMESTAMP] = new Domain(PropelTypes.TIMESTAMP);

		_schemaDomainMap[PropelTypes.BOOLEAN] = new Domain(PropelTypes.BOOLEAN, 'INTEGER');
	}

	void setSchemaDomainMapping(Domain domain) {
		_schemaDomainMap[domain.getType()] = domain;
	}

	@override
	String getDatabaseType() {
		String cla = this.runtimeType.toString();
		return cla.substring(0, cla.indexOf('Platform')).toLowerCase();
	}



	@override
	int getMaxColumnNameLength() => 64;

	@override
	String getNativeIdMethod() => PropelPlatformInterface.IDENTITY;

	@override
	Domain getDomainForType(String propelType) {
		if (!_schemaDomainMap.containsKey(propelType)) {
			throw new Exception('Cannot map unknown Propel type "${propelType}" to native database type');
		}
		Domain d = _schemaDomainMap[propelType];
		return d;
	}

	String getSequenceName(Table table) {
		throw new UnimplementedError('getSequenceName not implemented yet');
	}

	String getAddTablesDDL(Database database) {
		StringBuffer ret = new StringBuffer(getBeginDDL());
		for (Table t in database.getTablesForSql()) {
			ret.write(getCommentBlockDDL(t.getName()));
			ret.write(getDropTableDDL(t));
			ret.write(getAddTableDDL(t));
			ret.write(getAddIndicesDDL(t));
			ret.write(getAddForeignKeysDDL(t));
		}
		ret.write(getEndDDL());
		return ret.toString();
	}

	String getBeginDDL() => '';

	String getEndDDL() => '';

	String getDropTableDDL(Table table) => "\nDROP TABLE ${quoteIdentifier(table.getName())};\n";

	String getAddTableDDL(Table table) {
		String tableDescription = table.hasDescription() ? getCommentLineDDL(table.getDescription()) : '';

		List<String> lines = new List<String>();

		for (Column column in table.getColumns()) {
			lines.add(getColumnDDL(column));
		}

		if (table.hasPrimaryKey()) {
			lines.add(getPrimaryKeyDDL(table));
		}

		for (Unique unique in table.getUnices()) {
			lines.add(getUniqueDDL(unique));
		}
		return '''
${tableDescription}CREATE TABLE ${quoteIdentifier(table.getName())}
(
	${lines.join(",\n")}
);
''';
	}

	@override
	String getNullString(bool notNull) => notNull ? 'NOT NULL' : '';

	@override
	String getAutoIncrement() => 'IDENTITY';

	@override
	String getColumnDDL(Column col) {
		Domain domain = col.getDomain();
		List<String> ddl = new List<String>();
		ddl.add(quoteIdentifier(col.getName()));
		String sqlType = domain.getSqlType();

		if (hasSize(sqlType)) {
			ddl.add("${sqlType}${domain.printSize()}");
		} else {
			ddl.add(sqlType);
		}
		String def = getColumnDefaultValueDDL(col);
		if (def != null && def.isNotEmpty) {
			ddl.add(def);
		}

		String notNull = getNullString(col.isNotNull());
		if (notNull != null && notNull.isNotEmpty) {
			ddl.add(notNull);
		}

		String autoIncrement = col.getAutoIncrementString();
		if (autoIncrement != null && autoIncrement.isNotEmpty) {
			ddl.add(autoIncrement);
		}

		return ddl.join(' ');
	}

	@override
	String getColumnDefaultValueDDL(Column col) {
		StringBuffer def = new StringBuffer('');
		ColumnDefaultValue defaultValue = col.getDefaultValue();
		if (defaultValue != null) {
			def.write('DEFAULT ');
			if (defaultValue.isExpression()) {
				def.write(defaultValue.getValue());
			} else {
				if (col.isTextType()) {
					def.write(quote(defaultValue.getValue()));
				} else if (col.getType() == PropelTypes.BOOLEAN || col.getType() == PropelTypes.BOOLEAN_EMU) {
					def.write(getBooleanString(defaultValue.getValue()));
				} else if (col.getType() == PropelTypes.ENUM) {
					def.write(col.getValueSet().indexOf(defaultValue.getValue()));
				} else {
					def.write(defaultValue.getValue());
				}
			}
		}
		return def.toString();
	}

	@override
	String getColumnListDDL(List<Column> columns, [String delimiter = ',']) {
		List<String> list = new List<String>();
		for (Column column in columns) {
			list.add(quoteIdentifier(column.getName()));
		}
		return list.join(delimiter);
	}

	String getPrimaryKeyName(Table table) => "${table.getCommonName()}_PK";

	@override
	String getPrimaryKeyDDL(Table table) {
		if (table.hasPrimaryKey()) {
			return "PRIMARY KEY (${getColumnListDDL(table.getPrimaryKey())})";
		}
		return '';
	}

	String getDropPrimaryKeyDDL(Table table) => "\nALTER TABLE ${quoteIdentifier(table.getName())} DROP CONSTRAINT ${quoteIdentifier(getPrimaryKeyName(table))};\n";

	String getAddPrimaryKeyDDL(Table table) => "\nALTER TABLE ${quoteIdentifier(table.getName())} ADD ${getPrimaryKeyDDL(table)};\n";

	String getAddIndicesDDL(Table table) {
		StringBuffer ret = new StringBuffer();

		for (Index fk in table.getIndices()) {
			ret.write(getAddIndexDDL(fk));
		}

		return ret.toString();
	}

	String getAddIndexDDL(Index index) {
		return "\nCREATE ${index.isUnique() ? 'UNIQUE ' : ''}INDEX ${quoteIdentifier(index.getName())} ON ${quoteIdentifier(index.getTable().getName())} (${getColumnListDDL(index.getColumns())})";
	}

	String getDropIndexDDL(Index index) => "\nDROP INDEX ${quoteIdentifier(index.getName())};\n";

	String getIndexDDL(Index index) => "${index.isUnique() ? 'UNIQUE ' :'' }INDEX ${quoteIdentifier(index.getName())} (${getColumnListDDL(index.getColumns())})";

	String getUniqueDDL(Unique unique) => "UNIQUE (${getColumnListDDL(unique.getColumns())})";

	String getAddForeignKeysDDL(Table table) {
		StringBuffer ret = new StringBuffer();

		for (ForeignKey fk in table.getForeignKeys()) {
			ret.write(getAddForeignKeyDDL(fk));
		}

		return ret.toString();
	}

	String getAddForeignKeyDDL(ForeignKey fk) {
		if (fk.isSkipSql()) {
			return '';
		}

		return "\nALTER TABLE ${quoteIdentifier(fk.getTable().getName())} ADD ${getForeignKeyDDL(fk)};\n";
	}

	String getDropForeignKeyDDL(ForeignKey fk) {
		if (fk.isSkipSql()) {
			return '';
		}

		return "\nALTER TABLE ${quoteIdentifier(fk.getTable().getName())} DROP CONSTRAINT ${quoteIdentifier(fk.getName())};\n";
	}

	String getForeignKeyDDL(ForeignKey fk) {
		if (fk.isSkipSql()) {
			return '';
		}

		StringBuffer ret = new StringBuffer();
		ret.write("CONSTRAINT ${quoteIdentifier(fk.getName())}\n");
		ret.write("\tFOREIGN KEY (${getColumnListDDL(fk.getLocalColumnObjects())})\n");
		ret.write("\tREFERENCES ${quoteIdentifier(fk.getForeignTableName())} (${getColumnListDDL(fk.getForeignColumnObjects())})");

		if (fk.hasOnUpdate()) {
			ret.write("\n\tON UPDATE ${fk.getOnUpdate()}");
		}

		if (fk.hasOnDelete()) {
			ret.write("\n\tON DELETE ${fk.getOnDelete()}");
		}
		return ret.toString();
	}

	String getCommentLineDDL(String comment) => "-- ${comment}";

	String getCommentBlockDDL(String comment) => '''
-----------------------------------------------------------------------
-- ${comment}
-----------------------------------------------------------------------
''';

	//Unsupported: getModifyDatabaseDDL

	String getRenameTableDDL(String fromTableName, String toTableName) => "\nALTER TABLE ${quoteIdentifier(fromTableName)} RENAME TO ${quoteIdentifier(toTableName)};\n";

	//Unsupported: getModifyTableDDL

	//Unsupported: getModifyTableColumnsDDL

	//Unsupported: getModifyTablePrimaryKeyDDL

	//Unsupported: getModifyTableIndicesDDL

	//Unsupported: getModifyTableForeignKeysDDL

	String getRemoveColumnDDL(Column column) => "\nALTER TABLE ${quoteIdentifier(column.getTable().getName())} DROP COLUMN ${quoteIdentifier(column.getName())};\n";

	String getRenameColumnDDL(Column fromColumn, Column toColumn) => "\nALTER TABLE ${quoteIdentifier(fromColumn.getTable().getName())} RENAME COLUMN ${fromColumn.getName()} TO ${toColumn.getName()};\n";

	String getModifyColumnDDL(PropelColumnDiff columnDiff) {
		Column toColumn = columnDiff.getToColumn();
		return "\nALTER TABLE ${toColumn.getTable().getName()} MODIFY ${getColumnDDL(toColumn)};\n";
	}

	String getModifyColumnsDDL(List<PropelColumnDiff> columnDiffs) {
		List<String> lines = new List<String>();
		String tableName;
		for (PropelColumnDiff columnDiff in columnDiffs) {
			Column toColumn = columnDiff.getToColumn();
			if (null == tableName || tableName.isEmpty) {
				tableName = toColumn.getTable().getName();
			}
			lines.add(getColumnDDL(toColumn));
		}

		return "\nALTER TABLE ${quoteIdentifier(tableName)} MODIFY\n(\t${lines.join(",\n\t")}\n);\n";
	}

	String getAddColumnDDL(Column column) => "\nALTER TABLE ${quoteIdentifier(column.getTable().getName())} ADD ${getColumnDDL(column)};\n";

	String getAddColumnsDDL(List<Column> columns) {
		List<String> lines = new List<String>();
		String tableName;
		for (Column column in columns) {
			if (null == tableName || tableName.isEmpty) {
				tableName = column.getTable().getName();
			}
			lines.add(getColumnDDL(column));
		}
		return "\nALTER TABLE ${quoteIdentifier(tableName)} ADD\n(\n\t${lines.join(",\n\t")}\n);\n";
	}

	bool hasSize(String sqlType) => true;

	@override
	bool hasScale(String sqlType) => true;

	@override
	String quote(String text) {
		DDO con = getConnection();
		if (con != null) {
			return con.quote(text);
		}
		return "'${_disconnectedEscapeText(text)}'";
	}

	String _disconnectedEscapeText(String text) => text.replaceAll("'", "''");

	@override
	String quoteIdentifier(String text) => _isIdentifierQuotingEnabled ? '"${text.replaceAll('.', '"."')}"' : text;

	void setIdentifierQuoting([bool enabled = true]) {
		_isIdentifierQuotingEnabled = enabled;
	}

	bool getIdentifierQuoting() => _isIdentifierQuotingEnabled;

	@override
	bool supportsNativeDeleteTrigger() => false;

	@override
	bool supportsInsertNullPk() => true;

	@override
	bool hasStreamBlobImpl() => false;

	@override
	bool supportsSchemas() => false;

	@override
	String getBooleanString(Object b) {
		bool isTrue = false;
		if (b is String) {
			isTrue = (b.toLowerCase() == 'true' || b == '1' || b == 'y' || b.toLowerCase() == 'yes');
		} else if(b is bool) {
			isTrue = b;
		} else if(b is num) {
			isTrue = b == 1;
		}
		return isTrue ? '1' : '0';
	}

	@override
	String getTimestampFormatter() => 'Y-m-d H:i:s';

	@override
	String getTimeFormatter() => 'H:i:s';

	@override
	String getDateFormatter() => 'Y-m-d';
}
