part of database_reverse_engineer;

class Column extends PropelXmlElement {


	static const String DEFAULT_TYPE = "VARCHAR";
	static const String DEFAULT_VISIBILITY = 'public';
	static final List<String> valid_visibilities = ['public', 'protected', 'private'];

	String _name;
	String _description;
	String _phpName = null;
	String _phpNamingMethod;
	bool _isNotNull = false;
	String _size;
	String _namePrefix;
	String _accessorVisibility;
	String _mutatorVisibility;

	String _dartType;

	Table _parentTable;

	String _position;
	bool _isPrimaryKey = false;
	bool _isNodeKey = false;
	String _nodeKeySep;
	bool _isNestedSetLeftKey = false;
	bool _isNestedSetRightKey = false;
	bool _isTreeScopeKey = false;
	bool _isUnique = false;
	bool _isAutoIncrement = false;
	bool _isLazyLoad = false;
	String _defaultValue;
	String _referrers;
	bool _isPrimaryString = false;

	String _inheritanceType;
	String _isInheritance;
	String _isEnumeratedClasses;
	String _inheritanceList;
	String _needsTransactionInPostgres;

	List<String> _valueset = new List<String>();

	Domain _domain;

	Column(String this._name): super('column');

	@override
	void appendXml(XmlElement node) {
		// TODO: implement appendXml
	}

	@override
	void _setupObject() {
		// TODO: implement setupObject
	}
}
