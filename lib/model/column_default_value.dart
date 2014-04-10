part of database_reverse_engineer;

class ColumnDefaultValue {

	static const String TYPE_VALUE = 'value';
	static const String TYPE_EXPR = 'expr';

	String _value;

	String _type = ColumnDefaultValue.TYPE_VALUE;

	ColumnDefaultValue(this._value, [String type = null]) {
		if (type != null) {
			setType(type);
		}
	}

	String getType() => _type;

	void setType(String type) {
		_type = type;
	}

	bool isExpression() => _type == ColumnDefaultValue.TYPE_EXPR;

	String getValue() => _value;

	void setValue(String value) {
		_value = value;
	}

	bool equals(ColumnDefaultValue other) {
		if (this == other) {
			return true;
		}

		if (getType() != other.getType()) {
			return false;
		}

		List<String> equivalents = ['CURRENT_TIMESTAMP', 'NOW()'];
		if(equivalents.contains(getValue().toUpperCase()) && equivalents.contains(other.getValue().toUpperCase())){
			return true;
		}
		return false;
	}

}
