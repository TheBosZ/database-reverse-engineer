part of database_reverse_engineer;

class ConstraintNameGenerator implements NameGenerator {

	final bool DEBUG = false;

	/**
	 * First element of <code>inputs</code> should be of type {@link Database}, second
	 * should be a table name, third is the type identifier (spared if
	 * trimming is necessary due to database type length constraints),
	 * and the fourth is a <code>Integer</code> indicating the number
	 * of this contraint.
	 *
	 * @see        NameGenerator
	 * @throws     EngineException
	 */
	@override
	String generateName(List<Object> inputs) {
		Database db = inputs.elementAt(0) as Database;
		String name = inputs.elementAt(1) as String;
		String postFix = inputs.elementAt(2) as String;
		String constraint = inputs.elementAt(3) as String;


		int maxColumnNameLength = db.getPlatform().getMaxColumnNameLength();
		int maxBodyLength = (maxColumnNameLength - postFix.length - constraint.length - 2);
		if(maxBodyLength != -1 && name.length > maxBodyLength) {
			name = name.substring(0, maxBodyLength);
		}

		return "${name}${NameGenerator.STD_SEPARATOR_CHAR}${postFix}${NameGenerator.STD_SEPARATOR_CHAR}${constraint}";
	}
}
