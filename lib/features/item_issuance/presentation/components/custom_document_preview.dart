import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/common/components/base_modal.dart';
import '../../../../core/common/components/custom_dropdown_button.dart';
import '../../../../core/common/components/custom_dropdown_field.dart';
import '../../../../core/common/components/custom_filled_button.dart';
import '../../../../core/common/components/custom_form_text_field.dart';
import '../../../../core/common/components/custom_outline_button.dart';
import '../../../../core/enums/document_type.dart';
import '../../../../core/services/document_service/document_service.dart';
import '../../../../core/utils/delightful_toast_utils.dart';
import '../../../../init_dependencies.dart';

class CustomDocumentPreview<T> extends StatefulWidget {
  const CustomDocumentPreview({
    super.key,
    required this.documentObject,
    required this.docType,
  });

  final T documentObject;
  final DocumentType docType;

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

    _copyController.addListener(() {
      final newQuantity = int.tryParse(_copyController.text) ?? 0;
      _copyNotifier.value = newQuantity;
    });

    _copyNotifier.addListener(() {
      _copyController.text = _copyNotifier.value.toString();
    });
  }

  Future<void> _init() async {
    await _documentService.initialize();

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
    return BaseModal(
      width: 1200.0,
      height: 900.0,
      headerTitle: 'Preview Document',
      subtitle: 'Preview document before printing or saving locally.',
      content: _buildDocumentPreview(),
      footer: _buildActionRows(),
    );
  }

  Widget _buildDocumentPreview() {
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
        child: Row(
          children: [
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
                              build: (format) async => await _documentService
                                  .generateDocument(
                                    pageFormat: selectedPageFormat,
                                    orientation: selectedOrientation,
                                    data: widget.documentObject,
                                    docType: widget.docType,
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
    );
  }

  Widget _buildPreviewSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Print Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 18.0,
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
                //_buildOrientationSelection(),
                // const SizedBox(
                //   height: 20.0,
                // ),
                _buildPrintCopiesCounter(),
                const Divider(),
                // Add more settings here as needed
                // For instance, copies, color, orientation, etc.
                _buildPrintWithSystemDialog(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // pick or direct print

  Widget _buildDestinationSelection() {
    return ValueListenableBuilder(
        valueListenable: _selectedPrinter,
        builder: (context, selectedPrinter, child) {
          return CustomDropdownField(
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
          return CustomDropdownField(
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

  // Widget _buildPrintCopiesCounter() {
  //   return CustomCounterTextBox(
  //     label: 'Copies',
  //     controller: _copyController,
  //     quantity: _copyNotifier,
  //   );
  // }

  Widget _buildPrintCopiesCounter() {
    return ValueListenableBuilder(
      valueListenable: _copyNotifier,
      builder: (BuildContext context, int value, Widget? child) {
        return CustomFormTextField(
          label: 'Copies',
          controller: _copyController,
          isNumeric: true,
          suffixWidget: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  _copyNotifier.value++;
                  _copyController.text == _copyNotifier.value.toString();
                },
                child: const Icon(
                  Icons.keyboard_arrow_up,
                  size: 18.0,
                ),
              ),
              InkWell(
                onTap: () {
                  if (value != 1) {
                    _copyNotifier.value--;
                    _copyController.text == _copyNotifier.value.toString();
                  }
                },
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrintWithSystemDialog() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Print directly with system dialog:',
            softWrap: true,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                ),
          ),
        ),
        IconButton(
            onPressed: _onSystemPrintDialog,
            icon: const Icon(
              HugeIcons.strokeRoundedLink01,
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
          width: 180.0,
        ),
        const SizedBox(
          width: 10.0,
        ),
        CustomFilledButton(
          onTap: _onPrint,
          text: 'Print',
          width: 180.0,
          height: 40.0,
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
                .generateDocument(
                  pageFormat: _selectedPageFormat.value,
                  orientation: _selectedOrientation.value,
                  data: widget.documentObject,
                  docType: widget.docType,
                )
                .then((doc) => doc.save()),

            // await _documentService
            //     .generateICS(
            //         pageFormat: _selectedPageFormat.value,
            //         orientation: _selectedOrientation.value)
            //     .then(
            //       (doc) => doc.save(),
            //    ),
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
          .generateDocument(
            pageFormat: _selectedPageFormat.value,
            orientation: _selectedOrientation.value,
            data: widget.documentObject,
            docType: widget.docType,
          )
          .then((doc) => doc.save()),
    );
  }
}

void showCustomDocumentPreview<T>({
  required BuildContext context,
  required T documentObject,
  required DocumentType docType,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDocumentPreview(
        documentObject: documentObject,
        docType: docType,
      );
    },
  );
}

class OpenSystemPrintDialogIntent extends Intent {}
