part of database_reverse_engineer;

class Validator extends PropelXmlElement {
	Validator(String name): super(name);

	static const String TRANSLATE_NONE = "none";
	static const String TRANSLATE_GETTEXT = "gettext";

	Column _column;

	List<Object> _ruleList = new List<Object>();

	String _translate;

	Table _table;

	void setTable(Table table) {
		_table = table;
	}

	Table getTable() => _table;

	@override
	void _setupObject() {
		_column = getTable().getColumn(getAttribute('column'));
		_translate = getAttribute("translate", getTable().getDataBase().getDefaultTranslateMethod());
	}

	Object addRule(Object data) {
		throw new UnimplementedError('Rules not implemented yet');
	}

	List<Object> getRules() => _ruleList;

	String getColumnName() => _column.getName();

	void setColumn(Column col) {
		_column = col;
	}

	Column getColumn() => _column;

	void setTranslate(String method) {
		_translate = method;
	}

	String getTranslate() => _translate;

	@override
	void appendXml(XmlElement node) {
		node.addChild(new XmlElement('validator'));
		node.attributes['column'] = getColumnName();

		if(_translate != null) {
			node.attributes['translate'] = _translate;
		}

		_ruleList.forEach((Object r){
			//r.appendXml(node);
		});
	}
}
