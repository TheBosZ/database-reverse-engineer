part of database_reverse_engineer;

class ForeignKey extends PropelXmlElement {
	ForeignKey([String this._name]): super('foreign-key');
	String _name;
	String _foreignTableCommonName;
	String _foreignSchemaName;
	String _dartName;
	String _refDartName;
	String _defaultJoin;
	String _onUpdate = '';
	String _onDelete = '';
	Table _parentTable;
	List<String> _localColumns = new List<String>();
	List<String> _foreignColumns = new List<String>();

	bool _skipSql = false;

	static const String NONE = "";
	static const String NOACTION  = "NO ACTION";
	static const String CASCADE  = "CASCADE";
	static const String RESTRICT = "RESTRICT";
	static const String SETDEFAULT  = "SET DEFAULT";
	static const String SETNULL  = "SET NULL";

	@override
	void _setupObject() {
		_foreignTableCommonName = "${getTable().getDatabase().getTablePrefix()}${getAttribute('foreignTable')}";
		_foreignSchemaName = getAttribute('foreignSchema');
		if(_foreignSchemaName == null) {
			if(getTable().getSchema() != null) {
				_foreignSchemaName = getTable().getSchema();
			}
		}
		_name = getAttribute('name');
		_dartName = getAttribute('dartName');
		_refDartName = getAttribute('refDartName');
		_defaultJoin = getAttribute('defaultJoin');
		_onUpdate = getAttribute('onUpdate');
		_onDelete = getAttribute('onDelete');
		_skipSql = _booleanValue(getAttribute('skipSql'));
	}

	String normalizeFKey(String attrib) {
		if(attrib == null || attrib.toUpperCase() == 'NONE') {
			attrib = ForeignKey.NONE;
		}
		attrib = attrib.toUpperCase();
		if(attrib == 'SETNULL') {
			attrib = ForeignKey.SETNULL;
		}
		return attrib;
	}

	bool hasOnUpdate() => _onUpdate != ForeignKey.NONE;

	bool hasOnDelete() => _onDelete != ForeignKey.NONE;

	String getOnUpdate() => _onUpdate;

	String getOnDelete() => _onDelete;

	void setOnDelete(String v) {
		_onDelete = normalizeFKey(v);
	}

	void setOnUpdate(String v) {
		_onUpdate = normalizeFKey(v);
	}

	String getName() => _name;

	void setName(String v) {
		_name = v;
	}

	String getDartName() => _dartName;

	void setDartName(String v) {
		_dartName = v;
	}

	String getRefDartName() => _refDartName;

	void setRefDartName(String v) {
		_refDartName = v;
	}

	String getDefaultJoin() => _defaultJoin;

	void setDefaultJoin(String v) {
		_defaultJoin = v;
	}

	String getForeignTableName() {
		if(_foreignSchemaName != null && getTable().getDatabase().getPlatform().supportsSchemas()){
			return "${_foreignSchemaName}.${_foreignTableCommonName}";
		}
		return _foreignTableCommonName;
	}

	String getForeignTableCommonName() => _foreignTableCommonName;

	void setForeignTableCommonName(String v) {
		_foreignTableCommonName = v;
	}

	Table getForeignTable() => getTable().getDatabase().getTable(getForeignTableName());

	String getForeignSchemaName() => _foreignSchemaName;

	void setForeignSchemaName(String v) {
		_foreignSchemaName = v;
	}

	void setTable(Table parent) {
		_parentTable = parent;
	}

	Table getTable() => _parentTable;

	String getTableName() => _parentTable.getName();

	String getSchemaName() => _parentTable.getSchema();

	void addReference(Object p1, [Object p2 = null]) {
		if(p1 is Map) {
			addReference(p1['local'], p1['foreign']);
			return;
		}
		String p1name, p2name;
		if(p1 is Column) {
			p1name = p1.getName();
		} else {
			p1name = p1.toString();
		}

		if(p2 is Column) {
			p2name = p2.getName();
		} else {
			p2name = p2.toString();
		}
		_localColumns.add(p1name);
		_foreignColumns.add(p2name);
	}

	void clearReferences() {
		_localColumns.clear();
		_foreignColumns.clear();
	}

	List<String> getLocalColumns() => _localColumns;

	List<Column> getLocalColumnObjects() {
		List<Column> cols = new List<Column>();
		Table table = getTable();
		_localColumns.forEach((String colName){
			cols.add(table.getColumn(colName));
		});
		return cols;
	}

	String getLocalColumnName([int index = 0]) => _localColumns.elementAt(index);

	Column getLocalColumn([int index = 0]) => getTable().getColumn(getLocalColumnName(index));

	Map<String, String> getLocalForeignMapping() {
		Map<String, String> mapping = new Map<String, String>();
		for(int x = 0; x < _localColumns.length; ++x) {
			mapping[_localColumns.elementAt(x)] = _foreignColumns.elementAt(x);
		}
		return mapping;
	}

	Map<String, String> getForeignLocalMapping() {
		Map<String, String> locFor = getLocalForeignMapping();
		return {locFor.values: locFor.keys};
	}

	List<Map<String, Column>> getColumnObjectsMapping() {
		List<Map<String, Column>> mapping = new List<Map<String, Column>>();
		Table local = getTable();
		Table foreign = getForeignTable();
		for(int x = 0; x < _localColumns.length; ++x) {
			mapping.add({
				'local': local.getColumn(_localColumns.elementAt(x)),
				'foreign': foreign.getColumn(_foreignColumns.elementAt(x))
			});
		}
		return mapping;
	}

	String getMappedForeignColumn(String local) {
		Map<String, String> mapping = getLocalForeignMapping();
		if(mapping.containsKey(local)) {
			return mapping[local];
		}
		return null;
	}

	String getMappedLocalColumn(String foreign) {
		Map<String, String> mapping = getForeignLocalMapping();
		if(mapping.containsKey(foreign)) {
			return mapping[foreign];
		}
		return null;
	}

	List<String> getForeignColumns() => _foreignColumns;

	List<Column> getForeignColumnObjects() {
		List<Column> cols = new List<Column>();
		Table foreign = getForeignTable();
		_foreignColumns.forEach((String c){
			cols.add(foreign.getColumn(c));
		});
		return cols;
	}

	String getForeignColumnName([int index = 0]) => _foreignColumns.elementAt(index);

	Column getForeignColumn([int index = 0]) => getForeignTable().getColumn(getForeignColumnName(index));

	bool isLocalColumnsRequired() {
		bool result = true;
		getLocalColumns().forEach((String col){
			if(!getTable().getColumn(col).isNotNull()) {
				result = false;
			}
		});
		return result;
	}

	bool isForeignPrimaryKey() {
		Map<String, String> mapping = getLocalForeignMapping();
		Table foreign = getForeignTable();
		List<String> foreignPKCols = new List<String>();

		foreign.getPrimaryKey().forEach((Column pk){
			foreignPKCols.add(pk.getName());
		});

		List<String> foreignCols = new List<String>();
		getLocalColumns().forEach((String c){
			foreignCols.add(foreign.getColumn(mapping[c]).getName());
		});

		return foreignPKCols == foreignCols;
	}

	bool isComposite() => _localColumns.length > 1;

	bool isLocalPrimaryKey() {
		List<String> localCols = getLocalColumns();
		List<String> localPkCols = new List<String>();
		getTable().getPrimaryKey().forEach((Column c){
			localPkCols.add(c.getName());
		});

		return localCols == localPkCols;
	}

	void setSkipSql(bool v) {
		_skipSql = v;
	}

	bool isSkipSql() => _skipSql;

	bool isMatchedByInverseFK() => getInverseFK() != null;

	ForeignKey getInverseFK() {
		ForeignKey other;
		Table foreign = getForeignTable();
		Map<String, String> mapping = getForeignLocalMapping();
		foreign.getForeignKeys().forEach((ForeignKey fk){
			Map<String, String> fmap = fk.getLocalForeignMapping();
			if(fk.getTableName() == getTableName() && fmap == mapping) {
				other = fk;
			}
		});
		return other;
	}

	List<ForeignKey> getOtherFKs() {
		List<ForeignKey> fks = new List<ForeignKey>();
		getTable().getForeignKeys().forEach((ForeignKey fk){
			if(fk != this) {
				fks.add(fk);
			}
		});
		return fks;
	}

	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('foreign-key');
		child.attributes['foreignTable'] = getForeignTableCommonName();
		String schema = getForeignSchemaName();
		if(schema != null) {
			child.attributes['foreignSchema'] = schema;
		}

		child.attributes['name'] = getName();

		if(getDartName() != null) {
			child.attributes['dartName'] = getDartName();
		}

		if(getRefDartName() != null) {
			child.attributes['refDartName'] = getRefDartName();
		}

		if(getDefaultJoin() != null) {
			child.attributes['defaultJoin'] = getDefaultJoin();
		}

		if(getOnDelete() != null) {
			child.attributes['onDelete'] = getOnDelete();
		}

		if(getOnUpdate() != null) {
			child.attributes['onUpdate'] = getOnUpdate();
		}

		for(int x = 0; x < _localColumns.length; ++x) {
			XmlElement refNode = new XmlElement('reference');
			refNode.attributes['local'] = _localColumns.elementAt(x);
			refNode.attributes['foreign'] = _foreignColumns.elementAt(x);
			child.addChild(refNode);
		}

		_vendorInfos.forEach((String f, VendorInfo vi) {
			vi.appendXml(child);
		});

		node.addChild(child);
	}
}
