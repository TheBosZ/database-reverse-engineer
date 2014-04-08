part of database_reverse_engineer;

class MysqlSchemaParser extends BaseSchemaParser {

	bool _addVendorInfo = false;

	static final Map<String, String> _mysqlTypeMap = {
		'tinyint': PropelTypes.TINYINT,
		'smallint': PropelTypes.SMALLINT,
		'mediumint': PropelTypes.SMALLINT,
		'int': PropelTypes.INTEGER,
		'integer': PropelTypes.INTEGER,
		'bigint': PropelTypes.BIGINT,
		'int24': PropelTypes.BIGINT,
		'real': PropelTypes.REAL,
		'float': PropelTypes.FLOAT,
		'decimal': PropelTypes.DECIMAL,
		'numeric': PropelTypes.NUMERIC,
		'double': PropelTypes.DOUBLE,
		'char': PropelTypes.CHAR,
		'varchar': PropelTypes.VARCHAR,
		'date': PropelTypes.DATE,
		'time': PropelTypes.TIME,
		'year': PropelTypes.INTEGER,
		'datetime': PropelTypes.TIMESTAMP,
		'timestamp': PropelTypes.TIMESTAMP,
		'tinyblob': PropelTypes.BINARY,
		'blob': PropelTypes.BLOB,
		'mediumblob': PropelTypes.BLOB,
		'longblob': PropelTypes.BLOB,
		'longtext': PropelTypes.CLOB,
		'tinytext': PropelTypes.VARCHAR,
		'mediumtext': PropelTypes.LONGVARCHAR,
		'text': PropelTypes.LONGVARCHAR,
		'enum': PropelTypes.CHAR,
		'set': PropelTypes.CHAR,
		'bit': PropelTypes.BOOLEAN,
	};

	static final Map<String, int> _defaultTypeSizes = {
		'char': 1,
		'tinyint': 4,
		'smallint': 6,
		'int': 11,
		'bigint': 20,
		'decimal': 10,
	};

	MysqlSchemaParser(DDO dbh): super(dbh);

	Map<String, String> _getTypeMapping() {
		return MysqlSchemaParser._mysqlTypeMap;
	}

	@override
	Future<int> parse(Database database, [Object task = null]) {
		Completer c = new Completer();
		_dbh.query('SHOW TABLES').then((DDOStatement stmt) {
			List row;
			List<Table> tables = new List<Table>();
			while ((row = stmt.fetch(DDO.FETCH_NUM)) != null) {
				String name = row[0];
				if (name == getMigrationTable()) {
					continue;
				}
				Table table = new Table(name);
				database.addTable(table);
				tables.add(table);
			}

			tables.forEach((Table table){
				_addColumns(table);
			});

			tables.forEach((Table table){
				addForeignKeys(table);
				addIndexes(table);
				addPrimaryKey(table);
				if(_addVendorInfo) {
					addTableVendorInfo(table);
				}
			});
			c.complete(tables.length);
		});
		return c.future;
	}

	void _addColumns(Table table) {
		String tableName = table.getName();
		String databaseName = table.getDatabase().getName();

		_dbh.query("SHOW COLUMNS FROM `${tableName}`")
		.then((DDOStatement stmt) {
			Map<String, String> row;
			while((row = stmt.fetch(DDO.FETCH_ASSOC)) != null) {
				String name = row['Field'];
				_dbh.query(''' 
				SELECT
				COLUMN_COMMENT
				FROM information_schema.COLUMNS
				WHERE TABLE_NAME='${tableName}'
					AND TABLE_SCHEMA='${databaseName}'
					AND COLUMN_NAME='${name}' LIMIT 1
''').then((DDOStatement comState) {
					comState.fetchColumn().then((f) {
						row['Comment'] = f;
						bool isNull = row['Null'] == 'YES';
						bool autoIncrement = row['Extra'].contains('auto_increment');
						RegExp exp = new RegExp(r'^(\w+)[\(]?([\d,]*)[\)]?( |$)');
						RegExp expNoLength = new RegExp(r'^(\w+)\(');
						int size, precision, scale;
					String nativeType;
						if(exp.hasMatch(row['Type'])) {
							Match match = exp.firstMatch(row['Type']);
							nativeType = match.group(1);
							if(match.groupCount > 2) {
								int cpos = match.group(2).indexOf(',');
								if(cpos != -1) {
									size = precision = int.parse(match.group(2).substring(0, cpos));
									scale = int.parse(match.group(2).substring(cpos +1));
								} else {
									size = int.parse(match.group(2));
								}
							}
							_defaultTypeSizes.forEach((k, v) {
								if(nativeType == k && size == v) {
									size = null;
								}
							});
						} else if(expNoLength.hasMatch(row['Type'])) {
							nativeType = expNoLength.firstMatch(row['Type']).group(1);
						} else {
							nativeType = row['Type'];
						}

						String defaultValue = nativeType.contains(new RegExp(r'blob$|text$')) ? null : row['Default'];

						String propelType = getMappedPropelType(nativeType);
						if([PropelTypes.INTEGER, PropelTypes.BIGINT].contains(propelType) &&
								row['Comment'].indexOf('timestamp') == 0) {
							propelType = PropelTypes.INTEGER_TIMESTAMP;
						} else if(propelType == null) {
							propelType = Column.DEFAULT_TYPE;
							warn('Column [${tableName}.${name}] has a column type (${nativeType}) that the parser does not support.');
						}

						Column column = new Column(name);
						column.setTable(table);
						column.setDomainForType(propelType);
						column.getDomain().replaceSize(size);
						column.getDomain().replaceScale(scale);

						if(defaultValue != null) {
							if(propelType == PropelTypes.BOOLEAN) {
								if(defaultValue == '1') {
									defaultValue = 'true';
								}
								if(defaultValue == '0') {
									defaultValue = 'false';
								}
							}
							String type;
							if(defaultValue == 'CURRENT_TIMESTAMP') {
								type = ColumnDefaultValue.TYPE_EXPR;
							} else {
								type = ColumnDefaultValue.TYPE_VALUE;
							}
							column.getDomain().setDefaultValue(new ColumnDefaultValue(defaultValue, type));
						}
						column.setAutoIncrement(autoIncrement);
						column.setNotNull(!isNull);

						if(_addVendorInfo) {
							VendorInfo vi = getNewVendorInfoObject(row);
							column.addVendorInfo(vi);
						}
						table.addColumn(column);
					});
				});
			}
		});
	}

	@override
	Object getBuildProperty(String name) {
		// TODO: implement getBuildProperty
	}

	@override
	Object getConnection() {
		// TODO: implement getConnection
	}

	@override
	List<String> getWarnings() {
		// TODO: implement getWarnings
	}



	@override
	void setConnection(Object conn) {
		// TODO: implement setConnection
	}

	@override
	void setGeneratorConfig(Object config) {
		// TODO: implement setGeneratorConfig
	}

	@override
	Map<String, String> getTypeMapping() {
		// TODO: implement getTypeMapping
	}
}
