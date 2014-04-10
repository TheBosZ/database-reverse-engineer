library database_reverse_engineer;

import 'package:xml/xml.dart';
import 'package:dart_ddo/ddo.dart';
import 'dart:async';
import 'dart:convert';

export 'package:xml/xml.dart';

part 'model/propel_xml_element.dart';
part 'model/vendor_info.dart';
part 'model/id_method.dart';
part 'model/name_generator.dart';
part 'model/scoped_element.dart';
part 'model/propel_types.dart';
part 'model/column.dart';
part 'model/table.dart';
part 'model/domain.dart';
part 'model/database.dart';
part 'model/app_data.dart';
part 'model/validator.dart';
part 'model/foreign_key.dart';
part 'model/index.dart';
part 'model/unique.dart';
part 'model/name_factory.dart';
part 'model/dart_name_generator.dart';
part 'model/constraint_name_generator.dart';
part 'model/inheritance.dart';
part 'model/id_method_parameter.dart';
part 'model/column_default_value.dart';

part 'model/diff/propel_column_diff.dart';

part 'reverse/schema_parser.dart';
part 'reverse/base_schema_parser.dart';
part 'reverse/mysql/mysql_schema_parser.dart';

part 'platform/propel_platform_interface.dart';
part 'platform/default_platform.dart';
part 'platform/mysql_platform.dart';

part 'helpers.dart';
