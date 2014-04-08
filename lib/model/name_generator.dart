part of database_reverse_engineer;

//Interface only
abstract class NameGenerator {
	/**
	 * The character used by most implementations as the separator
	 * between name elements.
	 */
	static const String STD_SEPARATOR_CHAR = '_';

	/**
	 * Traditional method for converting schema table and column names
	 * to PHP names.  The <code>CONV_METHOD_XXX</code> static const Stringants
	 * define how names for columns and tables in the database schema
	 * will be converted to PHP source names.
	 *
	 * @see        PhpNameGenerator::underscoreMethod()
	 */
	static const String CONV_METHOD_UNDERSCORE = "underscore";

	/**
	 * Heavier method for converting schema table and column names
	 * to PHP names. Similar to {@link #CONV_METHOD_UNDERSCORE} but
	 * this one will pass only letters and numbers through and will
	 * use as separator any character that is not a letter or a number
	 * inside the string to be converted. The <code>CONV_METHOD_XXX</code>
	 * static const Stringants define how names for columns and tales in the
	 * database schema will be converted to PHP source names.
	 */
	static const String CONV_METHOD_CLEAN = "clean";

	/**
	 * Similar to {@link #CONV_METHOD_UNDERSCORE} except nothing is
	 * converted to lowercase.
	 *
	 * @see        PhpNameGenerator::phpnameMethod()
	 */
	static const String CONV_METHOD_PHPNAME = "phpname";

	/**
	 * Specifies no modification when converting from a schema column
	 * or table name to a PHP name.
	 */
	static const String CONV_METHOD_NOCHANGE = "nochange";

	/**
	 * Given a list of <code>String</code> objects, implements an
	 * algorithm which produces a name.
	 *
	 * @param      inputs Inputs used to generate a name.
	 * @return     The generated name.
	 * @throws     EngineException
	 */
	String generateName($inputs);
}
