import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/common/components/custom_counter_text_box.dart';
import '../../../../core/common/components/custom_dropdown_button.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/services/document_service.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../injection_container.dart';

class CustomDocumentPreview extends StatefulWidget {
  const CustomDocumentPreview({super.key});

  @override
  _CustomDocumentPreview createState() => _CustomDocumentPreview();
}

class _CustomDocumentPreview extends State<CustomDocumentPreview> {
  late DocumentService _documentService;
  late List<Printer?> _printers = [];
  final ValueNotifier<Printer?> _selectedPrinter = ValueNotifier(null);
  final ValueNotifier<PdfPageFormat> _selectedPageFormat =
      ValueNotifier(PdfPageFormat.a4);
  final ValueNotifier<pw.PageOrientation> _selectedOrientation =
      ValueNotifier(pw.PageOrientation.portrait);
  final _copyController = TextEditingController();
  final _copyNotifier = ValueNotifier<int>(1);

  @override
  void initState() {
    super.initState();
    _documentService = serviceLocator<DocumentService>();
    _init();
  }

  Future<void> _init() async {
    final printers = await Printing.listPrinters();

    if (printers.isNotEmpty) {
      _printers = printers;
      _selectedPrinter.value = _printers[0];
    }

    _copyController.text = _copyNotifier.value.toString();
  }

  @override
  void dispose() {
    _selectedPrinter.dispose();
    _selectedPageFormat.dispose();
    _selectedOrientation.dispose();
    _copyController.dispose();
    _copyNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift,
            LogicalKeyboardKey.keyP): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenSystemPrintDialogIntent:
              CallbackAction<OpenSystemPrintDialogIntent>(
            onInvoke: (Intent intent) async => _onSystemPrintDialog(),
          ),
        },
        child: Dialog(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            width: 1200,
            height: 900,
            child: Row(
              children: [
                // Left side: PDF Preview (to be enhanced in the next section)
                Expanded(
                  flex: 2,
                  child: Container(
                    //padding: EdgeInsets.all(16),
                    color: Colors.grey[200],
                    child: ValueListenableBuilder(
                        valueListenable: _selectedPageFormat,
                        builder: (context, selectedPageFormat, child) {
                          return ValueListenableBuilder(
                              valueListenable: _selectedOrientation,
                              builder: (context, selectedOrientation, child) {
                                return PdfPreview(
                                  previewPageMargin: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 5.0,
                                  ),
                                  maxPageWidth: 633.0,
                                  build: (format) async =>
                                      await _documentService
                                          .generateICS(
                                            selectedPageFormat,
                                            selectedOrientation,
                                          )
                                          .then((doc) => doc.save()),
                                  allowPrinting: false,
                                  allowSharing: false,
                                  canChangePageFormat:
                                      false, // Disables changing page format
                                  canChangeOrientation:
                                      false, // Disables changing orientation
                                );
                              });
                        }),
                  ),
                ),

                // Right side: Print settings
                Expanded(
                  child: _buildPreviewSettings(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewSettings() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Print',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                _buildDestinationSelection(),
                const SizedBox(
                  height: 20.0,
                ),
                _buildPaperSizeSelection(),
                const SizedBox(
                  height: 20.0,
                ),
                _buildOrientationSelection(),
                const SizedBox(
                  height: 20.0,
                ),
                _buildPrintCopiesCounter(),
                const Divider(),
                // Add more settings here as needed
                // For instance, copies, color, orientation, etc.
                _buildPrintWithSystemDialog(),
              ],
            ),
          ),
          const SizedBox(
            height: 30.0,
          ),
          _buildActionRows(),
        ],
      ),
    );
  }

  // pick or direct print

  Widget _buildDestinationSelection() {
    return ValueListenableBuilder(
        valueListenable: _selectedPrinter,
        builder: (context, selectedPrinter, child) {
          return CustomDropdownButton(
            value: selectedPrinter,
            onChanged: (Printer? value) {
              _selectedPrinter.value = value;
            },
            label: 'Destination',
            items: _printers
                .map((Printer? printer) => DropdownMenuItem(
                      value: printer,
                      child: Text(printer!.name),
                    ))
                .toList(),
          );
        });
  }

  Widget _buildPaperSizeSelection() {
    return ValueListenableBuilder(
        valueListenable: _selectedPageFormat,
        builder: (context, selectedPageFormat, child) {
          return CustomDropdownButton(
            value: selectedPageFormat,
            onChanged: (PdfPageFormat? format) {
              _selectedPageFormat.value = format!;
            },
            label: 'Paper Size',
            items: _buildPaperSizeMenuItems(),
          );
        });
  }

  List<DropdownMenuItem<PdfPageFormat>> _buildPaperSizeMenuItems() {
    return [
      DropdownMenuItem(
        value: PdfPageFormat.a4,
        child: Text(
          'A4 210 x 297 mm',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
      DropdownMenuItem(
        value: PdfPageFormat.letter,
        child: Text(
          'Letter 8 1/2 x 11 in',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
      DropdownMenuItem(
        value: PdfPageFormat.legal,
        child: Text(
          'Legal 8 1/2 x 14 in',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
      DropdownMenuItem(
        value: PdfPageFormat.a3,
        child: Text(
          'A3 297 x 420 mm',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    ];
  }

  Widget _buildOrientationSelection() {
    return ValueListenableBuilder(
        valueListenable: _selectedOrientation,
        builder: (context, selectedOrientation, child) {
          return CustomDropdownButton(
            value: selectedOrientation,
            onChanged: (pw.PageOrientation? value) {
              _selectedOrientation.value = value!;
            },
            label: 'Orientation',
            items: pw.PageOrientation.values
                .map((orientation) => DropdownMenuItem(
                    value: orientation,
                    child: Text(orientation.toString().split('.').last)))
                .toList(),
          );
        });
  }

  Widget _buildPrintCopiesCounter() {
    return CustomCounterTextBox(
      label: 'Copies',
      controller: _copyController,
      quantity: _copyNotifier,
    );
  }

  Widget _buildPrintWithSystemDialog() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Print using system dialog... (Ctrl+Shift+P)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w400,
              ),
        ),
        IconButton(
            onPressed: _onSystemPrintDialog,
            icon: const Icon(
              CupertinoIcons.link,
              size: 20.0,
            ))
      ],
    );
  }

  Widget _buildActionRows() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomOutlineButton(
          onTap: () => context.pop(),
          text: 'Cancel',
          height: 40.0,
        ),
        const SizedBox(
          width: 5.0,
        ),
        CustomFilledButton(
          onTap: _onPrint,
          text: 'Print',
        ),
      ],
    );
  }

  Future<void> _onPrint() async {
    if (_selectedPrinter.value != null) {
      try {
        for (int i = 1; i <= _copyNotifier.value; i++) {
          await Printing.directPrintPdf(
            printer: _selectedPrinter.value!,
            onLayout: (format) async => await _documentService
                .generateICS(
                    _selectedPageFormat.value, _selectedOrientation.value)
                .then(
                  (doc) => doc.save(),
                ),
          );
        }
        DelightfulToastUtils.showDelightfulToast(
          context: context,
          icon: Icons.check_circle_outline,
          title: 'Printing successfully.',
          subtitle: 'Document printed successfully.',
        );
      } catch (e) {
        DelightfulToastUtils.showDelightfulToast(
          context: context,
          icon: Icons.error_outline,
          title: 'Printing failed.',
          subtitle: e.toString(),
        );
      }
    }
  }

  Future<void> _onSystemPrintDialog() async {
    await Printing.layoutPdf(
      onLayout: (format) async => await _documentService
          .generateICS(_selectedPageFormat.value, _selectedOrientation.value)
          .then(
            (doc) => doc.save(),
          ),
    );
  }
}

void showCustomDocumentPreview(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CustomDocumentPreview();
    },
  );
}

class OpenSystemPrintDialogIntent extends Intent {}
