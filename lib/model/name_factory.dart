part of database_reverse_engineer;

class NameFactory {

	static const String DART_GENERATOR = 'DartNameGenerator';

	static const String CONSTRAINT_GENERATOR = 'ConstraintNameGenerator';

	static String generateName(String algorithmName, List<String> inputs) {
		NameGenerator generator;
		switch(algorithmName) {
			case NameFactory.DART_GENERATOR:
				generator = new DartNameGenerator();
				break;
			case NameFactory.CONSTRAINT_GENERATOR:
				generator = new ConstraintNameGenerator();
				break;
			default:
				throw new ArgumentError("'${algorithmName}' not a recongized generator");
		}
		return generator.generateName(inputs);
	}
}