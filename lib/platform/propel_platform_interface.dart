part of database_reverse_engineer;

abstract class PropelPlatformInterface {

	static const IDENTITY = 'identity';

	static const SEQUENCE = 'sequence';

	static const SERIAL = 'serial';

	void setConnection([DDO conn = null]);

	DDO getConnection();

	void setGeneratorConfig(Object config);

	String getDatabaseType();

	String getNativeIdMethod();

	int getMaxColumnNameLength();

	Domain getDomainForType(String propelType);

	String getNullString(bool notNull);

	String getAutoIncrement();

	String getColumnDDL(Column col);

	String getColumnDefaultValueDDL(Column col);

	String getColumnListDDL(List<Column> columns, [String delimiter = ',']);

	String getPrimaryKeyDDL(Table table);

	bool hasScale(String sqlType);

	String quote(String text);

	String quoteIdentifier(String text);

	bool supportsNativeDeleteTrigger();

	bool supportsInsertNullPk();

	bool supportsSchemas();

	String getBooleanString(Object tf);

	bool hasStreamBlobImpl();

	String getTimestampFormatter();

	String getDateFormatter();

	String getTimeFormatter();

}