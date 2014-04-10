part of database_reverse_engineer;

class PropelColumnDiff {

	Map<String, List<String>> _changedProperties = new Map<String, List<String>>();
	Column _fromColumn;
	Column _toColumn;

	void setChangedProperties(Map<String, List<String>> changed) {
		_changedProperties = changed;
	}

	Map<String, List<String>> getChangedProperties() => _changedProperties;

	void setFromColumn(Column from) {
		_fromColumn = from;
	}

	Column getFromColumn() => _fromColumn;

	void setToColumn(Column to) {
		_toColumn = to;
	}

	Column getToColumn() => _toColumn;

	PropelColumnDiff getReverseDiff() {
		PropelColumnDiff diff = new PropelColumnDiff();
		diff.setFromColumn(getToColumn());
		diff.setToColumn(getFromColumn());
		Map<String, List<String>> prop = new Map<String, List<String>>();
		getChangedProperties().forEach((String name, List<String> changes){
			prop[name] = changes.reversed.toList();
		});
		diff.setChangedProperties(prop);
		return diff;
	}

	String toString() {
		StringBuffer sb = new StringBuffer("    ");
		sb.write(getFromColumn().getFullyQualifiedName());
		sb.write(":\n");
		getChangedProperties().forEach((String name, List<String> values){
			sb.write("          ");
			sb.write(name);
			sb.write(": ");
			sb.write(JSON.encode(values));
			sb.write("\n");
		});
		return sb.toString();
	}
}