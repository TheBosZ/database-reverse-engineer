part of database_reverse_engineer;

abstract class BaseSchemaParser implements SchemaParser {

	DDO _dbh;

	List<String> _warnings;

	Object _generatorConfig; //GeneratorConfig object, I can't find a reference to it

	Map<String, String> _nativeToPropelTypeMap;

	Map<String, String> _reverseTypeMap;

	String _migrationTable = 'propel_migration';

	PropelPlatformInterface _platform;

	BaseSchemaParser(DDO this._dbh);

	void setConnection(DDO c) {
		_dbh = c;
	}

	DDO getConnection() => _dbh;

	void setMigrationTable(String table) {
		_migrationTable = table;
	}

	String getMigrationTable() => _migrationTable;

	void warn(String msg) {
		_warnings.add(msg);
	}

	List<String> getWarnings() => _warnings;

	void setGeneratorConfig(Object config) {
		_generatorConfig = config;
	}

	Object getGeneratorConfig() => _generatorConfig;

	String getBuildProperty(String name) {
		throw new UnimplementedError();
		if(_generatorConfig != null) {
			//return _generatorConfig.getBuildProperty(name);
		}
		return null;
	}

	Map<String, String> getTypeMapping();

	String getMappedPropelType(String nativeType) {
		if(_nativeToPropelTypeMap == null) {
			_nativeToPropelTypeMap = getTypeMapping();
		}
		if(_nativeToPropelTypeMap.containsKey(nativeType)) {
			return _nativeToPropelTypeMap[nativeType];
		}
		return null;
	}

	String getMappedNativeType(String propelType) {
		if(_reverseTypeMap == null) {
			_reverseTypeMap = new Map<String, String>();
			getTypeMapping().forEach((K, V){
				_reverseTypeMap[V] = K;
			});
		}
		return _reverseTypeMap.containsKey(propelType) ? _reverseTypeMap[propelType] : null;
	}

	VendorInfo getNewVendorInfoObject(Map<String, String> params) {
		String type = getPlatform().getDatabaseType();
		VendorInfo vi = new VendorInfo(type);
		vi.setParameters(params);
		return vi;
	}

	void setPlatform(Object platform) {
		_platform = platform;
	}

	PropelPlatformInterface getPlatform() {
		if(_platform == null) {
			_platform = getGeneratorConfig().getConfiguredPlatform();
		}
		return _platform;
	}
}