part of database_reverse_engineer;

class Database extends ScopedElement {
	Database([String this._name = null]): super('table');

	PropelPlatformInterface _platform;
	List<Table> _tableList = new List<Table>();
	String _curColumn;
	String _name;

	String _baseClass;
	String _basePeer;
	String _defaultIdMethod;
	String _defaultDartNamingMethod;
	String _defaultTranslateMethod;
	AppData _dbParent;
	Map<String, Table> _tablesByName = new Map<String, Table>();
	Map<String, Table> _tablesByLowercaseName = new Map<String, Table>();
	Map<String, Table> _tablesByDartName = new Map<String, Table>();
	bool _heavyIndexing;
	String _tablePrefix = '';

	String _defaultStringFormat;

	Map<String, Domain> _domainMap = new Map<String, Domain>();

	Map<String, Object> _behaviors = new Map<String, Object>(); //I don't think we need this

	void _setupObject() {
		super._setupObject();
		_name = getAttribute('name');
		_baseClass = getAttribute('baseClass');
		_basePeer = getAttribute('basePeer');
		_defaultIdMethod = getAttribute('defaultIdMethod', IDMethod.NATIVE);
		_defaultDartNamingMethod = getAttribute('defaultDartNamingMethod', NameGenerator.CONV_METHOD_UNDERSCORE);
		_defaultTranslateMethod = getAttribute('defaultTranslateMethod', Validator.TRANSLATE_NONE);
		_heavyIndexing = _booleanValue(getAttribute('heavyIndexing'));
		_tablePrefix = getAttribute('tablePrefix', getBuildProperty('tablePrefix'));
		_defaultStringFormat = getAttribute('defaultStringFormat', 'YAML');
	}

	PropelPlatformInterface getPlatform() => _platform;

	void setPlatform(PropelPlatformInterface platform) {
		_platform = platform;
	}

	String getName() => _name;

	void setName(String name) {
		_name = name;
	}

	String getBaseClass() => _baseClass;

	void setBaseClass(String v) {
		_baseClass = v;
	}

	String getBasePeer() => _basePeer;

	void setBasePeer(String v) {
		_basePeer = v;
	}

	String getDefaultIdMethod() => _defaultIdMethod;

	void setDefaultIdMethod(String v) {
		_defaultIdMethod = v;
	}

	String getDefaultDartNamingMethod() => _defaultDartNamingMethod;

	void setDefaultDartNamingMethod(String v) {
		_defaultDartNamingMethod = v;
	}

	String getDefaultTranslateMethod() => _defaultTranslateMethod;

	void setDefaultTranslateMethod(String v) {
		_defaultTranslateMethod = v;
	}

	void setDefaultStringFormat(String v) {
		_defaultStringFormat = v;
	}

	String getDefaultStringFormat() => _defaultStringFormat;

	bool isHeavyIndexing() => getHeavyIndexing();

	bool getHeavyIndexing() => _heavyIndexing;

	void setHeavyIndexing(bool v) {
		_heavyIndexing = v;
	}

	List<Table> getTables() => _tableList;

	int countTables() => _tableList.length;

	List<Table> getTablesForSql() {
		List<Table> tables = new List<Table>();
		_tableList.forEach((Table t) {
			if (!t.isSkipSql()) {
				tables.add(t);
			}
		});
		return tables;
	}

	bool hasTable(String name, [bool caseInsensitive = false]) {
		if (caseInsensitive) {
			return _tablesByLowercaseName.containsKey(name.toLowerCase());
		}
		return _tablesByName.containsKey(name);
	}

	Table getTable(String name, [bool caseInsensitive = false]) {
		if (hasTable(name, caseInsensitive)) {
			if (caseInsensitive) {
				return _tablesByLowercaseName[name.toLowerCase()];
			}
			return _tablesByName[name];
		}
		return null;
	}

	bool hasTableByDartName(String dartName) => _tablesByDartName.containsKey(dartName);

	Table getTableByDartName(String dartName) {
		if (hasTableByDartName(dartName)) {
			return _tablesByDartName[dartName];
		}
		return null;
	}

	Table addTable(Object data) {
		if (data is Table) {
			data.setDatabase(this);
			if (data.getSchema() == null) {
				data.setSchema(getSchema());
			}
			if (hasTable(data.getName())) {
				return getTable(data.getName());
			}
			_tableList.add(data);
			_tablesByName[data.getName()] = data;
			_tablesByLowercaseName[data.getName().toLowerCase()] = data;
			String namespace;
			if (data.getNamespace().contains(r'\\')) {
				data.setNamespace(data.getNamespace().substring(1));
			} else if ((namespace = getNamespace()) != null) {
				if (data.getNamespace() == null) {
					data.setNamespace(namespace);
				} else {
					data.setNamespace('${namespace}\\${data.getNamespace()}');
				}
			}
			if (data.getPackage() == null) {
				data.setPackage(getPackage());
			}
			return data;

		} else {
			Table tbl = new Table();
			tbl.setDatabase(this);
			tbl.setSchema(getSchema());
			tbl.loadFromXML(data);
			return addTable(tbl);
		}
	}

	void setAppData(AppData parent) {
		_dbParent = parent;
	}

	AppData getAppData() => _dbParent;

	Domain addDomain(Object data) {
		if (data is Domain) {
			data.setDatabase(this);
			_domainMap[data.getName()] = data;
			return data;
		}
		Domain domain = new Domain();
		domain.setDatabase(this);
		domain.loadFromXML(data);
		return addDomain(domain);
	}

	Domain getDomain(String domainName) {
		if (_domainMap.containsKey(domainName)) {
			return _domainMap[domainName];
		}
		return null;
	}

	Object getGeneratorConfig() {
		AppData d = getAppData();
		if (d != null) {
			return d.getGeneratorConfig();
		}
		return null;
	}

	@override
	Object getBuildProperty(String key) {
		Object config = getGeneratorConfig();
		if (config != null) {
			return config.getBuildProperty(key);
		}
		return '';
	}

	Object addBehavior(Object bdata) {
		throw new UnimplementedError('Behaviors not implemented');
	}

	Map getBehaviors() => _behaviors;

	bool hasBehavior(String name) => _behaviors.containsKey(name);

	Object getBehavior(String name) => _behaviors[name];

	String getTablePrefix() => _tablePrefix;

	Object getNextTableBehavior() {
		throw new UnimplementedError('Behaviors not implemented');
	}

	void doFinalInitialization() {
		setupTableReferrers();
		getTables().forEach((Table t){
			t.doFinalInitialization();
			t.setupReferrers(true);
		});
	}

	void setupTableReferrers() {
		getTables().forEach((Table t){
			t.doNaming();
			t.setupReferrers();
		});
	}

	@override
	void appendXml(XmlElement node) {
		node.addChild(new XmlElement('database'));
		node.attributes['name'] = _name;
		if(_pkg != null) {
			node.attributes['package'] = _pkg;
		}

		if(_defaultIdMethod != null) {
			node.attributes['defaultIdMethod'] = _defaultIdMethod;
		}

		if(_baseClass != null) {
			node.attributes['baseClass'] = _baseClass;
		}

		if(_basePeer != null) {
			node.attributes['basePeer'] = _basePeer;
		}

		if(_defaultDartNamingMethod != null) {
			node.attributes['defaultDartNamingMethod'] = _defaultDartNamingMethod;
		}

		if(_defaultTranslateMethod != null) {
			node.attributes['defaultTranslateMethod'] = _defaultTranslateMethod;
		}

		_vendorInfos.forEach((String k, VendorInfo v){
			v.appendXml(node);
		});

		_tableList.forEach((Table t){
			t.appendXml(node);
		});
	}
}
