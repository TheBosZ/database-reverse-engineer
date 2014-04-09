part of database_reverse_engineer;

class Index extends PropelXmlElement {
	Index([String this._indexName]): super('index');

	final bool DEBUG = false;

	String _indexName;

	Table _parentTable;

	List<String> _indexColumns;

	Map<String, int> _indexColumnSizes = new Map<String, int>();

	void _createName() {
		Table t = getTable();
		List<Object> inputs = new List<Object>();
		inputs.add(t.getDatabase());
		inputs.add(t.getCommonName());
		inputs.add(isUnique() ? 'U' : 'I');
		if(isUnique()) {
			inputs.add(table.getUnices().length + 1);
		} else {
			inputs.add(table.getIndicies().length + 1);
		}

		_indexName = NameFactory.generateName(NameFactory.CONSTRAINT_GENERATOR, inputs);
	}



	@override
	void _setupObject() {
		_indexName = getAttribute('name');
	}

	bool isUnique() {
		return false;
	}

	String getName() {
		if(_indexName == null) {
			_createName();
		}
		Database db = getTable().getDatabase();
		if(db != null) {
			return _indexName.substring(0, db.getPlatform().getMaxColumnNameLength());
		}
		return _indexName;
	}

	void setName(String name) {
		_indexName = name;
	}

	void setTable(Table parent) {
		_parentTable = parent;
	}

	Table getTable() => _parentTable;

	String getTableName() => _parentTable.getName();

	void addColumn(Object data) {
		if(data is Column) {
			_indexColumns.add(data.getName());
			if(data.getSize() != null && data.getSize() != 0) {
				_indexColumnSizes[data.getName()] = data.getSize();
			}
		} else if(data is Map<String, String>) {
			_indexColumns.add(data['name']);
			if(data.containsKey('size')) {
				_indexColumnSizes[data['name']] = int.parse(data['size']);
			}
		}
	}

	void setColumns(List<Column> indexCols) {
		_indexColumns = new List<String>();
		resetColumnSize();
		indexCols.forEach((Column c){
			addColumn(c);
		});
	}

	bool hasColumnSize(String colName) => _indexColumnSizes.containsKey(colName);

	int getColumnSize(String colName) {
		if(_indexColumnSizes.containsKey(colName)) {
			return _indexColumnSizes[colName];
		}
		return null;
	}

	void resetColumnSize() {
		_indexColumnSizes = new Map<String, int>();
	}

	bool hasColumnAtPosition(int pos, String name, [int size = null, bool caseInsensitive = false]) {
		if(_indexColumns.length >= pos) {
			return false;
		}

		bool test = caseInsensitive ?
			_indexColumns.elementAt(pos).toLowerCase() != name.toLowerCase()
			: _indexColumns.elementAt(pos) != name;
		if(test) {
			return false;
		}
		if(size != null && _indexColumnSizes[name] != size) {
			return false;
		}
		return true;
	}

	bool hasColumns() => _indexColumns.isNotEmpty;

	List<String> getColumns() => _indexColumns;


	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('index');
		child.attributes['name'] = getName();

		_indexColumns.forEach((String cname){
			XmlElement colNode = new XmlElement('index-column');
			colNode.attributes['name'] = cname;
			child.addChild(colNode);
		});

		node.addChild(child);
		_vendorInfos.forEach((String k, VendorInfo vi) {
			vi.appendXml(child);
		});
	}
}
