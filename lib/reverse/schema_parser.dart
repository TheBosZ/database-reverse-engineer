part of database_reverse_engineer;

abstract class SchemaParser {
	DDO getConnection();

	void setConnection(DDO conn);

	void setGeneratorConfig(Object config); //This is supposed to be GeneratorConfig

	Object getBuildProperty(String name);

	List<String> getWarnings();

	Future<int> parse(Database database, [Object task = null]);
}