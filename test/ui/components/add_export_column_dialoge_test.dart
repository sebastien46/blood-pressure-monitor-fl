import 'package:blood_pressure_app/components/dialoges/add_export_column_dialoge.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/subsettings/export_import/export_field_format_documentation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  group('AddExportColumnDialoge', () {
    testWidgets('should show everything on load', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(AddExportColumnDialoge(settings: Settings(),)));
      expect(widgetTester.takeException(), isNull);

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('CSV-title'), findsOneWidget);
      expect(find.text('Field format'), findsOneWidget);
      expect(find.text('Please enter a value'), findsOneWidget);
      expect(find.text('null'), findsOneWidget);
      expect(find.byType(MeasurementListRow), findsOneWidget);
      expect(find.byIcon(Icons.info_outline).hitTestable(), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsNWidgets(2));
    });
    testWidgets('should prefill values', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(
          AddExportColumnDialoge(initialColumn: UserColumn('id', 'csvTitle', r'formatPattern$SYS'), settings: Settings(),),
      ),);
      expect(widgetTester.takeException(), isNull);

      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('CSV-title'), findsAtLeastNWidgets(1));
      expect(find.text('Field format'), findsAtLeastNWidgets(1));
      expect(find.text('csvTitle'), findsOneWidget);
      expect(find.text(r'formatPattern$SYS'), findsOneWidget);
      expect(find.byType(MeasurementListRow), findsOneWidget);
      expect(find.byIcon(Icons.info_outline).hitTestable(), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsNWidgets(2));
    });
    testWidgets('should show preview', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(
          AddExportColumnDialoge(initialColumn: UserColumn('id', 'csvTitle', r'formatPattern$SYS'), settings: Settings(),),
      ),);
      await widgetTester.pumpAndSettle();

      expect(find.text('Please enter a value'), findsNothing);
      expect(find.text('null'), findsNothing);
      expect(find.textContaining('formatPattern'), findsNWidgets(2));
      expect(find.textContaining('RowDataFieldType.sys'), findsOneWidget);
    });
    testWidgets('should open format Info screen', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(AddExportColumnDialoge(settings: Settings(),)));

      expect(find.byType(InformationScreen), findsNothing);

      expect(find.byIcon(Icons.info_outline).hitTestable(), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.info_outline).hitTestable(),);
      await widgetTester.pumpAndSettle();

      expect(find.byType(InformationScreen), findsOneWidget);
    });
  });
  group('showAddExportColumnDialoge', () {
    testWidgets('should open AddExportColumnDialoge', (widgetTester) async {
      await loadDialoge(widgetTester, (context) => showAddExportColumnDialoge(context, Settings()));

      expect(find.byType(AddExportColumnDialoge), findsOneWidget);
    });
    testWidgets('should return null on cancel', (widgetTester) async {
      dynamic returnedValue = false;
      await loadDialoge(widgetTester, (context) async => returnedValue = await showAddExportColumnDialoge(context, Settings()));

      expect(returnedValue, false);
      expect(find.byIcon(Icons.close), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.close));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddExportColumnDialoge), findsNothing);
      expect(returnedValue, null);
    });
    testWidgets('should save entered values', (widgetTester) async {
      dynamic returnedValue = false;
      await loadDialoge(widgetTester, (context) async => returnedValue = await showAddExportColumnDialoge(context, Settings()));

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(returnedValue, false);

      expect(find.ancestor(of: find.text(localizations.csvTitle).first, matching: find.byType(TextFormField)),
          findsAtLeastNWidgets(1),);
      await widgetTester.enterText(
          find.ancestor(of: find.text(localizations.csvTitle).first, matching: find.byType(TextFormField)),
          'testCsvTitle',);

      expect(find.ancestor(of: find.text(localizations.csvTitle).first, matching: find.byType(TextFormField)),
          findsAtLeastNWidgets(1),);
      await widgetTester.enterText(
          find.ancestor(of: find.text(localizations.fieldFormat).first, matching: find.byType(TextFormField)),
          r'test$SYSformat',);

      expect(find.text(localizations.btnSave), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnSave));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddExportColumnDialoge), findsNothing);
      expect(returnedValue, isA<UserColumn>()
          .having((p0) => p0.csvTitle, 'csvTitle', 'testCsvTitle')
          .having((p0) => p0.formatter.formatPattern, 'formatter', r'test$SYSformat'),);
    });
    testWidgets('should keep internalIdentifier on edit', (widgetTester) async {
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      dynamic returnedValue = false;
      await loadDialoge(widgetTester, (context) async => returnedValue =
        await showAddExportColumnDialoge(context, Settings(),
          UserColumn('initialInternalIdentifier', 'csvTitle', 'formatPattern'),
      ),);

      expect(returnedValue, false);

      expect(find.ancestor(of: find.text(localizations.csvTitle).first, matching: find.byType(TextFormField)),
          findsAtLeastNWidgets(1),);
      await widgetTester.enterText(
          find.ancestor(of: find.text(localizations.csvTitle).first, matching: find.byType(TextFormField)),
          'changedCsvTitle',);

      expect(find.text(localizations.btnSave), findsOneWidget);
      await widgetTester.tap(find.text(localizations.btnSave));
      await widgetTester.pumpAndSettle();

      expect(find.byType(AddExportColumnDialoge), findsNothing);
      expect(returnedValue, isA<UserColumn>()
          .having((p0) => p0.internalIdentifier, 'identifier', 'userColumn.initialInternalIdentifier'),);
    });
  });

}
