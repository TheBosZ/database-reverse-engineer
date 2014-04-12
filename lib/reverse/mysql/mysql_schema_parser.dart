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

	Map<String, String> getTypeMapping() {
		return MysqlSchemaParser._mysqlTypeMap;
	}

	@override
	Future<int> parse(Database database, [Object task = null]) {
		Completer c = new Completer();
		_dbh.query('SHOW TABLES').then((DDOStatement stmt) {
			DDOResult row;
			List<Table> tables = new List<Table>();
			while ((row = stmt.fetch(DDO.FETCH_NUM)) != null) {
				String name = row.row.values.elementAt(0);
				if (name == getMigrationTable()) {
					continue;
				}
				Table table = new Table(name);
				database.addTable(table);
				tables.add(table);
			}

			Future.wait(tables.map((Table t) => _addColumns(t))).then((_) {
				Future.wait(tables.map((Table t) => addForeignKeys(t))).then((_){
					Future.wait(tables.map((Table t) => addIndexes(t))).then((_){
						Future.wait(tables.map((Table t) => addPrimaryKey(t))).then((_){
							if(_addVendorInfo) {
								Future.wait(tables.map((Table t) => addTableVendorInfo(t))).then((_){
									c.complete(tables.length);
								});
							} else {
								c.complete(tables.length);
							}
						});
					});
				});
			});
		});
		return c.future;
	}

	Future<DDOStatement> _getColumnDefinitions(Table table) => _dbh.query("SHOW COLUMNS FROM `${table.getName()}`");

	Future<DDOStatement> _getForeignKeyDefinitions(Table table) => _dbh.query("SHOW CREATE TABLE `${table.getName()}`");

	Future<DDOStatement> _getIndexDefinitions(Table table) => _dbh.query("SHOW INDEX FROM `${table.getName()}`");

	Future<DDOStatement> _getPrimaryKeyDefinitions(Table table) => _dbh.query("SHOW KEYS FROM `${table.getName()}`");

	Future<DDOStatement> _getVendorInfoDefinitions(Table table) => _dbh.query("SHOW TABLE STATUS LIKE '${table.getName()}'");

	Future<DDOStatement> _getColumnComment(Column column) => _dbh.query(''' 
    			SELECT
    			COLUMN_COMMENT
    			FROM information_schema.COLUMNS
    			WHERE TABLE_NAME='${column.getTable().getName()}'
    				AND TABLE_SCHEMA='${column.getTable().getDatabase().getName()}'
    				AND COLUMN_NAME='${column.getName()}' LIMIT 1
    ''');

	Future _addColumns(Table table) {
		Completer c = new Completer();
		String databaseName = table.getDatabase().getName();

		 _getColumnDefinitions(table).then((DDOStatement stmt) {
			Map<String, String> row;
			DDOResult r;
			while ((r = stmt.fetch(DDO.FETCH_ASSOC)) != null) {
				row = r.row;
				String name = row['Field'];
				bool isNull = row['Null'] == 'YES';
				bool autoIncrement = row['Extra'].contains('auto_increment');
				RegExp exp = new RegExp(r'^(\w+)[\(]?([\d,]*)[\)]?( |$)');
				RegExp expNoLength = new RegExp(r'^(\w+)\(');
				int size, precision, scale;
				String nativeType;
				if (exp.hasMatch(row['Type'])) {
					Match match = exp.firstMatch(row['Type']);
					nativeType = match.group(1);
					if (match.groupCount > 2) {
						int cpos = match.group(2).indexOf(',');
						if (cpos != -1) {
							size = precision = int.parse(match.group(2).substring(0, cpos));
							scale = int.parse(match.group(2).substring(cpos + 1));
						} else {
							String s = match.group(2);
							size = s != null && s.isNotEmpty ? int.parse(s) : null;
						}
					}
					for(String k in _defaultTypeSizes.keys) {
						int v = _defaultTypeSizes[k];
						if (nativeType == k && size == v) {
							size = null;
						}
					}
				} else if (expNoLength.hasMatch(row['Type'])) {
					nativeType = expNoLength.firstMatch(row['Type']).group(1);
				} else {
					nativeType = row['Type'];
				}

				String defaultValue = nativeType.contains(new RegExp(r'blob$|text$')) ? null : row['Default'];

				String propelType = getMappedPropelType(nativeType);
				if ([PropelTypes.INTEGER, PropelTypes.BIGINT].contains(propelType) && row['Comment'] != null && row['Comment'] is String && row['Comment'].indexOf('timestamp') == 0) {
					propelType = PropelTypes.INTEGER_TIMESTAMP;
				} else if (propelType == null) {
					propelType = Column.DEFAULT_TYPE;
					warn('Column [${table.getName()}.${name}] has a column type (${nativeType}) that the parser does not support.');
				}

				Column column = new Column(name);
				column.setTable(table);
				column.setDomainForType(propelType);
				column.getDomain().replaceSize(size);
				column.getDomain().replaceScale(scale);
				if (defaultValue != null) {
					if (propelType == PropelTypes.BOOLEAN) {
						if (defaultValue == '1') {
							defaultValue = 'true';
						}
						if (defaultValue == '0') {
							defaultValue = 'false';
						}
					}
					String type;
					if (defaultValue == 'CURRENT_TIMESTAMP') {
						type = ColumnDefaultValue.TYPE_EXPR;
					} else {
						type = ColumnDefaultValue.TYPE_VALUE;
					}
					column.getDomain().setDefaultValue(new ColumnDefaultValue(defaultValue, type));
				}
				column.setAutoIncrement(autoIncrement);
				column.setNotNull(!isNull);

				if (_addVendorInfo) {
					VendorInfo vi = getNewVendorInfoObject(row);
					column.addVendorInfo(vi);
				}
				table.addColumn(column);
				//Future t = _getColumnComment(column).then((DDOStatement comState) {
					//row['Comment'] = comState.fetchColumn();

				//});
			}
			c.complete();
		});
		return c.future;
	}

	Future addForeignKeys(Table table) {
		Completer c = new Completer();
		_getForeignKeyDefinitions(table).then((DDOStatement stmt) {
			Database database = table.getDatabase();
			DDOResult row;
			Map<String, ForeignKey> foreignKeys;

			while ((row = stmt.fetch(DDO.FETCH_NUM)) != null) {

				foreignKeys = new Map<String, ForeignKey>();
				RegExp regEx = new RegExp(r"CONSTRAINT `([^`]+)` FOREIGN KEY \((.+)\) REFERENCES `([^`]*)` \((.+)\)(.*)");
				if (regEx.hasMatch(row.row.values.first)) {
					for(Match match in row.row.values.first) {
						String name = match.group(1);
						String rawlcol = match.group(2);
						String ftbl = match.group(3);
						String rawfcol = match.group(4);
						String fkey = match.group(5);
						List<String> lcols = new List<String>();
						for(String piece in rawlcol.split('`, `')) {
							lcols.add(piece.replaceAll('`', '').trim());
						}

						List<String> fcols = new List<String>();
						for(String piece in rawfcol.split('`, `')) {
							fcols.add(piece.replaceAll('`', '').trim());
						}

						Map<String, String> fkactions = {
							'ON DELETE': ForeignKey.RESTRICT,
							'ON UPDATE': ForeignKey.RESTRICT,
						};

						if (fkey != null && fkey.isNotEmpty) {
							for(String fkaction in fkactions.keys) {
								String result;
								RegExp r = new RegExp("${fkaction} (${ForeignKey.CASCADE}|${ForeignKey.SETNULL})");
								if (r.hasMatch(fkey)) {
									fkactions[fkaction] = r.firstMatch(fkey).group(1);
								}
							}
						}

						for(String key in fkactions.keys) {
							String action = fkactions[key];
							if (action == ForeignKey.RESTRICT) {
								fkactions[key] = null;
							}
						}

						List<Column> localColumns = new List<Column>();
						List<Column> foreignColumns = new List<Column>();
						Table foreignTable = database.getTable(ftbl, true);

						for(String fcol in fcols) {
							foreignColumns.add(foreignTable.getColumn(fcol));
						}
						for(String lcol in lcols) {
							localColumns.add(table.getColumn(lcol));
						}

						if (!foreignKeys.containsKey(name)) {
							ForeignKey fk = new ForeignKey(name);
							fk.setForeignTableCommonName(foreignTable.getCommonName());
							fk.setForeignSchemaName(foreignTable.getSchema());
							fk.setOnDelete(fkactions['ON DELETE']);
							fk.setOnUpdate(fkactions['ON UPDATE']);
							table.addForeignKey(fk);
							foreignKeys[name] = fk;
						}

						for (int x = 0; x < localColumns.length; ++x) {
							foreignKeys[name].addReference(localColumns.elementAt(x), foreignColumns.elementAt(x));
						}
					}
				}
			}
			c.complete();
		});
		return c.future;
	}

	Future addIndexes(Table table) {

		return _getIndexDefinitions(table).then((DDOStatement stmt) {
			Map<String, Index> indexes = new Map<String, Index>();
			DDOResult row;

			while ((row = stmt.fetch(DDO.FETCH_ASSOC)) != null) {
				String colName = row.row['Column_name'];
				String name = row.row['Key_name'];

				if (name == 'PRIMARY') {
					continue;
				}

				if (!indexes.containsKey(name)) {
					bool isUnique = row.row['Non_unique'] == 0;
					if (isUnique) {
						indexes[name] = new Unique(name);
					} else {
						indexes[name] = new Index(name);
					}
					if (_addVendorInfo) {
						VendorInfo vi = getNewVendorInfoObject(row.row);
						indexes[name].addVendorInfo(vi);
					}
					table.addIndex(indexes[name]);
				}
				indexes[name].addColumn(table.getColumn(colName));
			}

		});
	}

	Future addPrimaryKey(Table table) {
		Completer c = new Completer();
		_getPrimaryKeyDefinitions(table).then((DDOStatement stmt) {
			DDOResult row;
			while ((row = stmt.fetch(DDO.FETCH_ASSOC)) != null) {
				if (row.row['Key_name'] != 'PRIMARY') {
					continue;
				}
				String name = row.row['Column_name'];
				table.getColumn(name).setPrimaryKey(true);
			}
			c.complete();
		});

		return c.future;
	}

	Future addTableVendorInfo(Table table) {
		Completer c = new Completer();
		_getVendorInfoDefinitions(table).then((DDOStatement stmt) {
			DDOResult row = stmt.fetch(DDO.FETCH_ASSOC);
			VendorInfo vi = getNewVendorInfoObject(row.row);
			table.addVendorInfo(vi);
			c.complete();
		});
		return c.future;
	}

	@override
	Object getBuildProperty(String name) {
		throw new UnimplementedError();
	}

	@override
	Object getConnection() {
		throw new UnimplementedError();
	}

	@override
	List<String> getWarnings() {
		throw new UnimplementedError();
	}

	@override
	void setConnection(Object conn) {
		throw new UnimplementedError();
	}

	@override
	void setGeneratorConfig(Object config) {
		throw new UnimplementedError();
	}
}
