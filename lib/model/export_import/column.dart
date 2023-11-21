import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/reocord_formatter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract interface class ExportColumnI {
  /// Unique internal identifier that is used to identify a column in the app.
  ///
  /// A identifier can be any string, but is usually structured with a prefix and
  /// a name. For example `buildin.sys`, `user.fancyvalue` or `convert.myheartsys`.
  /// These examples are not guaranteed to be the prefixes used in the rest of the
  /// app.
  /// 
  /// It should not be used instead of [csvTitle].
  String get internalIdentifier;

  /// Column title in a csv file.
  ///
  /// May not contain characters intended for CSV column separation (e.g. `,`).
  String get csvTitle;

  /// Column title in user facing places that don't require strict rules.
  /// 
  /// It will be displayed on the exported PDF file or in the column selection.
  String userTitle(AppLocalizations localizations);
  
  /// Converter associated with this column.
  Formatter get formatter;
}

/// Convert [BloodPressureRecord]s from and to strings and provide metadata about the conversion.
class ExportColumn { // TODO: change this class so it implements the interface.
  /// Create object that turns data into strings.
  ///
  /// Example: ExportColumn(internalColumnName: 'pulsePressure', columnTitle: 'Pulse pressure', formatPattern: '{{$SYS-$DIA}}')
  ExportColumn({required this.internalName, required this.columnTitle, required String formatPattern, this.editable = true, this.hidden = false}) {
    this.formatPattern = formatPattern.replaceAll('{{}}', '');
    _formatter = ScriptedFormatter(formatPattern);
  }

  late final Formatter _formatter;

  /// pure name as in the title of the csv file and for internal purposes. Should not contain special characters and spaces.
  late final String internalName;

  /// Display title of the column. Possibly localized
  late final String columnTitle;

  /// Pattern to create the field contents from:
  /// It supports inserting values for $TIMESTAMP, $SYS $DIA $PUL, $COLOR and $NOTE. Where $TIMESTAMP is the time since unix epoch in milliseconds.
  /// To format a timestamp in the same format as the $TIMESTAMP variable, $FORMAT(<timestamp>, <formatString>).
  /// It is supported to use basic mathematics inside of double brackets ("{{}}"). In case one of them is not present in the record, -1 is provided.
  /// The following math is supported:
  /// Operations: [+, -, *, /, %, ^]
  /// One-parameter functions [ abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh ]
  /// Two-parameter functions [ log, nrt, pow ]
  /// Constants [ e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2 ]
  /// The full math interpreter specification can be found here: https://pub.dev/documentation/function_tree/latest#interpreter
  ///
  /// The String is processed in the following order:
  /// 1. variable replacement
  /// 2. Math
  /// 3. Date format
  late final String formatPattern;

  @Deprecated('will be replaced by the data structure the column is stored in')
  final bool editable; // TODO: remove

  /// doesn't show up as unused / hidden field in list
  final bool hidden;

  factory ExportColumn.fromJson(Map<String, dynamic> json, [editable = true, hidden = false]) =>
    ExportColumn(
      internalName: json['internalColumnName'],
      columnTitle: json['columnTitle'],
      formatPattern: json['formatPattern'],
      editable: editable,
      hidden: hidden
    );

  Map<String, dynamic> toJson() => {
    'internalColumnName': internalName,
    'columnTitle': columnTitle,
    'formatPattern': formatPattern
  };

  /// Turns a [BloodPressureRecord] into a string as defined in the [formatPattern].
  String formatRecord(BloodPressureRecord record) => _formatter.encode(record);

  /// Parses records if [isReversible] is true else returns an empty list
  List<(RowDataFieldType, dynamic)> parseRecord(String formattedRecord) => [
    if (_formatter.decode(formattedRecord) != null)
      _formatter.decode(formattedRecord)!
  ];

  /// Checks if the pattern can be used to parse records. This is the case when the pattern contains variables without
  /// containing curly brackets or commas.
  bool get isReversible => _formatter.restoreAbleType != null;

  RowDataFieldType? get parsableFormat => _formatter.restoreAbleType;

  @override
  String toString() {
    return 'ExportColumn{internalColumnName: $internalName, columnTitle: $columnTitle, formatPattern: $formatPattern}';
  }
}

/// Type a [ExportColumn] can be parsed as.
enum RowDataFieldType {
  timestamp, sys, dia, pul, notes, color;

  String localize(AppLocalizations localizations) {
    switch(this) {
      case RowDataFieldType.timestamp:
        return localizations.timestamp;
      case RowDataFieldType.sys:
        return localizations.sysLong;
      case RowDataFieldType.dia:
        return localizations.diaLong;
      case pul:
        return localizations.pulLong;
      case RowDataFieldType.notes:
        return localizations.notes;
      case RowDataFieldType.color:
        return localizations.color;
    }
  }
}