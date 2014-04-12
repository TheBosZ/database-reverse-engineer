part of database_reverse_engineer;

class Index extends PropelXmlElement {
	Index([String this._indexName]): super('index');

	final bool DEBUG = false;

	String _indexName;

	Table _parentTable;

	List<Column> _indexColumns = new List<Column>();

	Map<String, int> _indexColumnSizes = new Map<String, int>();

	void _createName() {
		Table t = getTable();
		List<Object> inputs = new List<Object>();
		inputs.add(t.getDatabase());
		inputs.add(t.getCommonName());
		inputs.add(isUnique() ? 'U' : 'I');
		if (isUnique()) {
			inputs.add(t.getUnices().length + 1);
		} else {
			inputs.add(t.getIndices().length + 1);
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
		if (_indexName == null) {
			_createName();
		}
		Database db = getTable().getDatabase();
		if (db != null) {
			int maxLength = db.getPlatform().getMaxColumnNameLength();
			return _indexName.length > maxLength ? _indexName.substring(0, db.getPlatform().getMaxColumnNameLength()) : _indexName;
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
		if (data is Column) {
			_indexColumns.add(data);
			if (data.getSize() != null && data.getSize() != 0) {
				_indexColumnSizes[data.getName()] = data.getSize();
			}
		} else {
			Column c = new Column();
			c.loadFromXML(data);
			addColumn(c);
		}
	}

	void setColumns(List<Column> indexCols) {
		_indexColumns = new List<Column>();
		resetColumnSize();
		indexCols.forEach((Column c) {
			addColumn(c);
		});
	}

	bool hasColumnSize(String colName) => _indexColumnSizes.containsKey(colName);

	int getColumnSize(String colName) {
		if (_indexColumnSizes.containsKey(colName)) {
			return _indexColumnSizes[colName];
		}
		return null;
	}

	void resetColumnSize() {
		_indexColumnSizes = new Map<String, int>();
	}

	bool hasColumnAtPosition(int pos, String name, [int size = null, bool caseInsensitive = false]) {
		if (_indexColumns.length >= pos) {
			return false;
		}

		bool test = caseInsensitive ? _indexColumns.elementAt(pos).getName().toLowerCase() != name.toLowerCase() : _indexColumns.elementAt(pos).getName() != name;
		if (test) {
			return false;
		}
		if (size != null && _indexColumnSizes[name] != size) {
			return false;
		}
		return true;
	}

	bool hasColumns() => _indexColumns.isNotEmpty;

	List<Column> getColumns() => _indexColumns;


	@override
	void appendXml(XmlElement node) {
		XmlElement child = new XmlElement('index');
		child.attributes['name'] = getName();

		for (Column c in _indexColumns) {
			XmlElement colNode = new XmlElement('index-column');
			colNode.attributes['name'] = c.getName();
			child.addChild(colNode);
		}
		for (VendorInfo vi in _vendorInfos.values) {
			vi.appendXml(child);
		}

		node.addChild(child);

	}
}
