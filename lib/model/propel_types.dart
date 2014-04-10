part of database_reverse_engineer;

/**
 * A class that maps PropelTypes to Dart native types, PDO types (and Creole types).
 *
 * @author     Hans Lellelid <hans@xmpl.org> (Propel)
 * @version    $Revision: 2076 $
 * @package    propel.generator.model
 */
class PropelTypes {

	static const String CHAR = "CHAR";
	static const String VARCHAR = "VARCHAR";
	static const String LONGVARCHAR = "LONGVARCHAR";
	static const String CLOB = "CLOB";
	static const String CLOB_EMU = "CLOB_EMU";
	static const String NUMERIC = "NUMERIC";
	static const String DECIMAL = "DECIMAL";
	static const String TINYINT = "TINYINT";
	static const String SMALLINT = "SMALLINT";
	static const String INTEGER = "INTEGER";
	static const String INTEGER_TIMESTAMP = "INTEGER_TIMESTAMP";
	static const String BIGINT = "BIGINT";
	static const String REAL = "REAL";
	static const String FLOAT = "FLOAT";
	static const String DOUBLE = "DOUBLE";
	static const String BINARY = "BINARY";
	static const String VARBINARY = "VARBINARY";
	static const String LONGVARBINARY = "LONGVARBINARY";
	static const String BLOB = "BLOB";
	static const String DATE = "DATE";
	static const String TIME = "TIME";
	static const String TIMESTAMP = "TIMESTAMP";
	static const String BU_DATE = "BU_DATE";
	static const String BU_TIMESTAMP = "BU_TIMESTAMP";
	static const String BOOLEAN = "BOOLEAN";
	static const String BOOLEAN_EMU = "BOOLEAN_EMU";
	static const String OBJECT = "OBJECT";
	static const String DART_ARRAY = "ARRAY";
	static const String ENUM = "ENUM";

	static final List<String> TEXT_TYPES = [PropelTypes.CHAR, PropelTypes.VARCHAR, PropelTypes.LONGVARCHAR, PropelTypes.CLOB, PropelTypes.DATE, PropelTypes.TIME, PropelTypes.TIMESTAMP, PropelTypes.BU_DATE, PropelTypes.BU_TIMESTAMP];

	static final List<String> LOB_TYPES = [PropelTypes.VARBINARY, PropelTypes.LONGVARBINARY, PropelTypes.BLOB];

	static final List<String> TEMPORAL_TYPES = [PropelTypes.DATE, PropelTypes.TIME, PropelTypes.TIMESTAMP, PropelTypes.BU_DATE, PropelTypes.BU_TIMESTAMP, PropelTypes.INTEGER_TIMESTAMP];

	static final List<String> NUMERIC_TYPES = [PropelTypes.SMALLINT, PropelTypes.TINYINT, PropelTypes.INTEGER, PropelTypes.BIGINT, PropelTypes.FLOAT, PropelTypes.DOUBLE, PropelTypes.NUMERIC, PropelTypes.DECIMAL, PropelTypes.REAL, PropelTypes.INTEGER_TIMESTAMP];

	static final List<String> BOOLEAN_TYPES = [PropelTypes.BOOLEAN, PropelTypes.BOOLEAN_EMU];

	static const String CHAR_NATIVE_TYPE = "string";
	static const String VARCHAR_NATIVE_TYPE = "string";
	static const String LONGVARCHAR_NATIVE_TYPE = "string";
	static const String CLOB_NATIVE_TYPE = "string";
	static const String CLOB_EMU_NATIVE_TYPE = "string";
	static const String NUMERIC_NATIVE_TYPE = "string";
	static const String DECIMAL_NATIVE_TYPE = "string";
	static const String TINYINT_NATIVE_TYPE = "int";
	static const String SMALLINT_NATIVE_TYPE = "int";
	static const String INTEGER_NATIVE_TYPE = "int";
	static const String BIGINT_NATIVE_TYPE = "string";
	static const String REAL_NATIVE_TYPE = "float";
	static const String FLOAT_NATIVE_TYPE = "float";
	static const String DOUBLE_NATIVE_TYPE = "float";
	static const String BINARY_NATIVE_TYPE = "string";
	static const String VARBINARY_NATIVE_TYPE = "string";
	static const String LONGVARBINARY_NATIVE_TYPE = "string";
	static const String BLOB_NATIVE_TYPE = "string";
	static const String BU_DATE_NATIVE_TYPE = "string";
	static const String DATE_NATIVE_TYPE = "string";
	static const String TIME_NATIVE_TYPE = "string";
	static const String TIMESTAMP_NATIVE_TYPE = "string";
	static const String BU_TIMESTAMP_NATIVE_TYPE = "string";
	static const String BOOLEAN_NATIVE_TYPE = "bool";
	static const String BOOLEAN_EMU_NATIVE_TYPE = "bool";
	static const String OBJECT_NATIVE_TYPE = "";
	static const String DART_ARRAY_NATIVE_TYPE = "list";
	static const String ENUM_NATIVE_TYPE = "string";

	/**
	 * Mapping between Propel types and Dart native types.
	 *
	 * @var        array
	 */
	static final Map<String, String> propelToDartNativeMap = {
		PropelTypes.CHAR: PropelTypes.CHAR_NATIVE_TYPE,
		PropelTypes.VARCHAR: PropelTypes.VARCHAR_NATIVE_TYPE,
		PropelTypes.LONGVARCHAR: PropelTypes.LONGVARCHAR_NATIVE_TYPE,
		PropelTypes.CLOB: PropelTypes.CLOB_NATIVE_TYPE,
		PropelTypes.CLOB_EMU: PropelTypes.CLOB_EMU_NATIVE_TYPE,
		PropelTypes.NUMERIC: PropelTypes.NUMERIC_NATIVE_TYPE,
		PropelTypes.DECIMAL: PropelTypes.DECIMAL_NATIVE_TYPE,
		PropelTypes.TINYINT: PropelTypes.TINYINT_NATIVE_TYPE,
		PropelTypes.SMALLINT: PropelTypes.SMALLINT_NATIVE_TYPE,
		PropelTypes.INTEGER: PropelTypes.INTEGER_NATIVE_TYPE,
		PropelTypes.INTEGER_TIMESTAMP: PropelTypes.INTEGER_NATIVE_TYPE,
		PropelTypes.BIGINT: PropelTypes.BIGINT_NATIVE_TYPE,
		PropelTypes.REAL: PropelTypes.REAL_NATIVE_TYPE,
		PropelTypes.FLOAT: PropelTypes.FLOAT_NATIVE_TYPE,
		PropelTypes.DOUBLE: PropelTypes.DOUBLE_NATIVE_TYPE,
		PropelTypes.BINARY: PropelTypes.BINARY_NATIVE_TYPE,
		PropelTypes.VARBINARY: PropelTypes.VARBINARY_NATIVE_TYPE,
		PropelTypes.LONGVARBINARY: PropelTypes.LONGVARBINARY_NATIVE_TYPE,
		PropelTypes.BLOB: PropelTypes.BLOB_NATIVE_TYPE,
		PropelTypes.DATE: PropelTypes.DATE_NATIVE_TYPE,
		PropelTypes.BU_DATE: PropelTypes.BU_DATE_NATIVE_TYPE,
		PropelTypes.TIME: PropelTypes.TIME_NATIVE_TYPE,
		PropelTypes.TIMESTAMP: PropelTypes.TIMESTAMP_NATIVE_TYPE,
		PropelTypes.BU_TIMESTAMP: PropelTypes.BU_TIMESTAMP_NATIVE_TYPE,
		PropelTypes.BOOLEAN: PropelTypes.BOOLEAN_NATIVE_TYPE,
		PropelTypes.BOOLEAN_EMU: PropelTypes.BOOLEAN_EMU_NATIVE_TYPE,
		PropelTypes.OBJECT: PropelTypes.OBJECT_NATIVE_TYPE,
		PropelTypes.DART_ARRAY: PropelTypes.DART_ARRAY_NATIVE_TYPE,
		PropelTypes.ENUM: PropelTypes.ENUM_NATIVE_TYPE,
	};

	/**
	 * Mapping between Propel types and Creole types (for rev-eng task)
	 *
	 * @var        array
	 */
	static final Map<String, String> propelTypeToCreoleTypeMap = {

		PropelTypes.CHAR: PropelTypes.CHAR,
		PropelTypes.VARCHAR: PropelTypes.VARCHAR,
		PropelTypes.LONGVARCHAR: PropelTypes.LONGVARCHAR,
		PropelTypes.CLOB: PropelTypes.CLOB,
		PropelTypes.NUMERIC: PropelTypes.NUMERIC,
		PropelTypes.DECIMAL: PropelTypes.DECIMAL,
		PropelTypes.TINYINT: PropelTypes.TINYINT,
		PropelTypes.SMALLINT: PropelTypes.SMALLINT,
		PropelTypes.INTEGER: PropelTypes.INTEGER,
		PropelTypes.BIGINT: PropelTypes.BIGINT,
		PropelTypes.REAL: PropelTypes.REAL,
		PropelTypes.FLOAT: PropelTypes.FLOAT,
		PropelTypes.DOUBLE: PropelTypes.DOUBLE,
		PropelTypes.BINARY: PropelTypes.BINARY,
		PropelTypes.VARBINARY: PropelTypes.VARBINARY,
		PropelTypes.LONGVARBINARY: PropelTypes.LONGVARBINARY,
		PropelTypes.BLOB: PropelTypes.BLOB,
		PropelTypes.DATE: PropelTypes.DATE,
		PropelTypes.TIME: PropelTypes.TIME,
		PropelTypes.TIMESTAMP: PropelTypes.TIMESTAMP,
		PropelTypes.BOOLEAN: PropelTypes.BOOLEAN,
		PropelTypes.BOOLEAN_EMU: PropelTypes.BOOLEAN_EMU,
		PropelTypes.OBJECT: PropelTypes.OBJECT,
		PropelTypes.DART_ARRAY: PropelTypes.DART_ARRAY,
		PropelTypes.ENUM: PropelTypes.ENUM,
		// These are pre-epoch dates, which we need to map to String type
		// since they cannot be properly handled using strtotime() -- or even numeric
		// timestamps on Windows.
		PropelTypes.BU_DATE: PropelTypes.VARCHAR,
		PropelTypes.BU_TIMESTAMP: PropelTypes.VARCHAR,

	};

	/**
	 * Mapping between Propel types and PDO type contants (for prepared statement setting).
	 *
	 * @var        array
	 */
	static final Map<String, String> propelTypeToDDOTypeMap = {
		PropelTypes.CHAR: DDO.PARAM_STR,
		PropelTypes.VARCHAR: DDO.PARAM_STR,
		PropelTypes.LONGVARCHAR: DDO.PARAM_STR,
		PropelTypes.CLOB: DDO.PARAM_STR,
		PropelTypes.CLOB_EMU: DDO.PARAM_STR,
		PropelTypes.NUMERIC: DDO.PARAM_INT,
		PropelTypes.DECIMAL: DDO.PARAM_STR,
		PropelTypes.TINYINT: DDO.PARAM_INT,
		PropelTypes.SMALLINT: DDO.PARAM_INT,
		PropelTypes.INTEGER: DDO.PARAM_INT,
		PropelTypes.INTEGER_TIMESTAMP: DDO.PARAM_INT,
		PropelTypes.BIGINT: DDO.PARAM_INT,
		PropelTypes.REAL: DDO.PARAM_STR,
		PropelTypes.FLOAT: DDO.PARAM_STR,
		PropelTypes.DOUBLE: DDO.PARAM_STR,
		PropelTypes.BINARY: DDO.PARAM_STR,
		PropelTypes.VARBINARY: DDO.PARAM_LOB,
		PropelTypes.LONGVARBINARY: DDO.PARAM_LOB,
		PropelTypes.BLOB: DDO.PARAM_LOB,
		PropelTypes.DATE: DDO.PARAM_STR,
		PropelTypes.TIME: DDO.PARAM_STR,
		PropelTypes.TIMESTAMP: DDO.PARAM_STR,
		PropelTypes.BOOLEAN: DDO.PARAM_BOOL,
		PropelTypes.BOOLEAN_EMU: DDO.PARAM_INT,
		PropelTypes.OBJECT: DDO.PARAM_STR,
		PropelTypes.DART_ARRAY: DDO.PARAM_STR,
		PropelTypes.ENUM: DDO.PARAM_INT,

		// These are pre-epoch dates, which we need to map to String type
		// since they cannot be properly handled using strtotime() -- or even numeric
		// timestamps on Windows.
		PropelTypes.BU_DATE: DDO.PARAM_STR,
		PropelTypes.BU_TIMESTAMP: DDO.PARAM_STR,
	};

	/**
	 * Return native Dart type which corresponds to the
	 * Creole type provided. Use in the base object class generation.
	 *
	 * @param      $propelType The Propel type name.
	 * @return     string Name of the native Dart type
	 */
	static String getDartNative(String propelType) {
		return PropelTypes.propelToDartNativeMap[propelType];
	}

	/**
	 * Returns the correct Creole type _name_ for propel added types
	 *
	 * @param      $type the propel added type.
	 * @return     string Name of the the correct Creole type (e.g. "VARCHAR").
	 */
	static String getCreoleType(String type) {
		return PropelTypes.propelTypeToCreoleTypeMap[type];
	}

	/**
	 * Resturns the DDO type (PropelTypes.PARAM_* constant) value.
	 * @return     int
	 */
	static Object getDDOType(String type) {
		return PropelTypes.propelTypeToDDOTypeMap[type];
	}

	/**
	 * Get array of Propel types.
	 *
	 * @return     array string[]
	 */
	static List<String> getPropelTypes() {
		return PropelTypes.propelTypeToCreoleTypeMap.keys.toList();
	}

	/**
	 * Whether passed type is a temporal (date/time/timestamp) type.
	 *
	 * @param      string $type Propel type
	 * @return     boolean
	 */
	static bool isTemporalType(String type) {
		return PropelTypes.TEMPORAL_TYPES.contains(type);
	}

	/**
	 * Returns true if values for the type need to be quoted.
	 *
	 * @param      string $type The Propel type to check.
	 * @return     boolean True if values for the type need to be quoted.
	 */
	static bool isTextType(String type) {
		return PropelTypes.TEXT_TYPES.contains(type);
	}

	/**
	 * Returns true if values for the type are numeric.
	 *
	 * @param      string $type The Propel type to check.
	 * @return     boolean True if values for the type need to be quoted.
	 */
	static bool isNumericType(String type) {
		return PropelTypes.NUMERIC_TYPES.contains(type);
	}

	/**
	 * Returns true if values for the type are boolean.
	 *
	 * @param      string $type The Propel type to check.
	 * @return     boolean True if values for the type need to be quoted.
	 */
	static bool isBooleanType(String type) {
		return PropelTypes.BOOLEAN_TYPES.contains(type);
	}

	/**
	 * Returns true if type is a LOB type (i.e. would be handled by Blob/Clob class).
	 * @param      string $type Propel type to check.
	 * @return     boolean
	 */
	static bool isLobType(String type) {
		return PropelTypes.LOB_TYPES.contains(type);
	}

	/**
	 * Convenience method to indicate whether a passed-in Dart type is a primitive.
	 *
	 * @param      string dartType The Dart type to check
	 * @return     boolean Whether the Dart type is a primitive (string, int, boolean, float)
	 */
	static bool isDartPrimitiveType(String dartType) {
		return ["bool", "int", "double", "float", "string"].contains(dartType);
	}

	/**
	 * Convenience method to indicate whether a passed-in Dart type is a numeric primitive.
	 *
	 * @param      string dartType The Dart type to check
	 * @return     boolean Whether the Dart type is a primitive (string, int, boolean, float)
	 */
	static bool isDartPrimitiveNumericType(String dartType) {
		return ["bool", "int", "double", "float"].contains(dartType);
	}

	/**
	 * Convenience method to indicate whether a passed-in Dart type is an object.
	 *
	 * @param      string dartType The Dart type to check
	 * @return     boolean Whether the Dart type is a primitive (string, int, boolean, float)
	 */
	static bool isDartObjectType(String dartType) {
		return (!PropelTypes.isDartPrimitiveType(dartType) && !["resource", "array"].contains(dartType));
	}
}
