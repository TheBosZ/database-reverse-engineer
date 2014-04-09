part of database_reverse_engineer;

class DefaultPlatform implements PropelPlatformInterface {

	@override
	String getAutoIncrement() {
		// TODO: implement getAutoIncrement
	}

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
	DDO getConnection() {
		// TODO: implement getConnection
	}

	@override
	String getDatabaseType() {
		// TODO: implement getDatabaseType
	}

	@override
	String getDateFormatter() {
		// TODO: implement getDateFormatter
	}

	@override
	Domain getDomainForType(String propelType) {
		// TODO: implement getDomainForType
	}

	@override
	int getMaxColumnNameLength() {
		// TODO: implement getMaxColumnNameLength
	}

	@override
	String getNativeIdMethod() {
		// TODO: implement getNativeIdMethod
	}

	@override
	String getNullString(bool notNull) {
		// TODO: implement getNullString
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
	void setConnection([DDO conn = null]) {
		// TODO: implement setConnection
	}

	@override
	void setGeneratorConfig(Object config) {
		// TODO: implement setGeneratorConfig
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
