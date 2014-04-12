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
		PropelTypes.getPropelTypes().forEach((String t) {
			_schemaDomainMap[t] = new Domain(t);
		});

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
		String ret = getBeginDDL();
		database.getTablesForSql().forEach((Table t){
			ret = "${ret}${getCommentBlockDDL(t.getName())}";
			ret = "${ret}${getDropTableDDL(t)}";
			ret = "${ret}${getAddTableDDL(t)}";
			ret = "${ret}${getAddIndicesDDL(t)}";
			ret = "${ret}${getAddForeignKeysDDL(t)}";
		});
		ret = "${ret}${getEndDDL()}";
		return ret;
	}

	String getBeginDDL() => '';

	String getEndDDL() => '';

	String getDropTableDDL(Table table) => "\nDROP TABLE ${quoteIdentifier(table.getName())};\n";

	@override
	String getNullString(bool notNull) => notNull ? 'NOT NULL' : '';

	@override
	String getAutoIncrement() => 'IDENTITY';

	String getCommentBlockDDL(String comment) => '''
-----------------------------------------------------------------------
-- ${comment}
-----------------------------------------------------------------------
''';

	@override
	String getBooleanString(Object tf) {
		// TODO: implement getBooleanString
	}

	@override
	String getColumnDDL(Column col) {
		// TODO: implement getColumnDDL
	}

	@override
	String getColumnDefaultValueDDL(Column col) {
		// TODO: implement getColumnDefaultValueDDL
	}

	@override
	String getColumnListDDL(List<Column> columns, [String delimiter = ',']) {
		// TODO: implement getColumnListDDL
	}



	@override
	String getDateFormatter() {
		// TODO: implement getDateFormatter
	}









	@override
	String getPrimaryKeyDDL(Table table) {
		// TODO: implement getPrimaryKeyDDL
	}

	@override
	String getTimeFormatter() {
		// TODO: implement getTimeFormatter
	}

	@override
	String getTimestampFormatter() {
		// TODO: implement getTimestampFormatter
	}

	@override
	bool hasScale(String sqlType) {
		// TODO: implement hasScale
	}

	@override
	bool hasStreamBlobImpl() {
		// TODO: implement hasStreamBlobImpl
	}

	@override
	String quote(String text) {
		// TODO: implement quote
	}

	@override
	String quoteIdentifier(String text) {
		// TODO: implement quoteIdentifier
	}

	@override
	bool supportsInsertNullPk() {
		// TODO: implement supportsInsertNullPk
	}

	@override
	bool supportsNativeDeleteTrigger() {
		// TODO: implement supportsNativeDeleteTrigger
	}

	@override
	bool supportsSchemas() {
		// TODO: implement supportsSchemas
	}
}
