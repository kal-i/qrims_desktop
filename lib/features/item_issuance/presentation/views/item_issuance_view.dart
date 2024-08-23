import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';
import '../components/custom_data_table.dart';
import '../components/custom_document_preview.dart';

class ItemIssuanceView extends StatefulWidget {
  const ItemIssuanceView({super.key});

  @override
  State<ItemIssuanceView> createState() => _ItemIssuanceViewState();
}

class _ItemIssuanceViewState extends State<ItemIssuanceView> {
  final _searchController = TextEditingController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: _buildClickableCardsRow(),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Expanded(
          flex: 2,
          child: _buildRecentlyGeneratedDocumentsRow(),
        ),
        const SizedBox(
          height: 20.0,
        ),
        // Expanded(
        //   flex: 4,
        //   child: PdfPreview(
        //     build: (format) => DocumentService().generatePdf().then((doc) => doc.save()),
        //     useActions: true,
        //   ),
        // ),

        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildActionsRow(),
              const SizedBox(
                height: 20.0,
              ),
              Expanded(
                child: CustomDataTable(
                  config: TableConfig(
                    headers: [
                      'PR ID',
                      'Requesting Officer',
                      'Issuance Type',
                      'Status',
                    ],
                    rows: [
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                      TableData(
                        columns: [
                          const Text('2024PR1'),
                          const Text('Alex Ander'),
                          const Text('ICS'),
                          const Text('Pending'),
                        ],
                      ),
                    ],
                  ),
                  onActionSelected: (index) {
                    print('Actions for row index: $index');
                  },
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              PaginationControls(
                  currentPage: 1,
                  totalRecords: 10,
                  pageSize: 10,
                  onPageChanged: (int page) {},
                  onPageSizeChanged: (int size) {})
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableCardsRow() {
    return Row(
      children: [
        const Expanded(
          child: ClickableCard(
            name: 'New Issuance',
            icon: CupertinoIcons.folder,
            //onTap: () => DocumentService().generatePdf(),
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        const Expanded(
          child: ClickableCard(
            name: 'New ICS',
            icon: Icons.note_outlined,
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: ClickableCard(
            name: 'New RIS',
            icon: CupertinoIcons.doc,
            onTap: () => showCustomDocumentPreview(context),
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        const Expanded(
          child: ClickableCard(
            name: 'New PAR',
            icon: CupertinoIcons.folder,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyGeneratedDocumentsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Recently generated documents',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        const Row(
          children: [
            Expanded(child: DocumentCard()),
            SizedBox(
              width: 15.0,
            ),
            Expanded(child: DocumentCard()),
            SizedBox(
              width: 15.0,
            ),
            Expanded(child: DocumentCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'All Items Issued',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 18.0,
              ),
        ),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFilterTableRows(),
            _buildActionButtons(),
          ],
        ),
      ],
    );
  }

  /// make this stateful
  /// fields: list of reusable button
  Widget _buildFilterTableRows() {
    return Container(
      height: 50.0,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: (context.watch<ThemeBloc>().state == AppTheme.light
            ? AppColor.lightSecondary
            : AppColor.darkSecondary),
      ),
      child: Row(
        children: [
          _buildReusableTableFilterButton(0, 'View All'),
          _buildReusableTableFilterButton(1, 'ICS'),
          _buildReusableTableFilterButton(2, 'RIS'),
          _buildReusableTableFilterButton(3, 'PAR'),
          _buildReusableTableFilterButton(4, 'Pending'),
          _buildReusableTableFilterButton(5, 'Approved'),
          _buildReusableTableFilterButton(6, 'Declined'),
        ],
      ),
    );
  }

  Widget _buildReusableTableFilterButton(int index, String text) {
    bool isSelected = _selectedIndex == index;

    return Material(
      borderRadius: BorderRadius.circular(10.0),
      color: isSelected
          ? Theme.of(context).scaffoldBackgroundColor
          : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        hoverColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        splashColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
        onTap: () => setState(() {
          _selectedIndex = index;
        }),
        child: Container(
          width: 100.0,
          height: 40.0,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ExpandableSearchButton(controller: _searchController),
        CustomOutlineButton(
          onTap: () {},
          text: 'Filter',
        ),
      ],
    );
  }
}

class ClickableCard extends StatelessWidget {
  const ClickableCard({
    super.key,
    required this.name,
    required this.icon,
    this.onTap,
  });

  final String name;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          hoverColor: Theme.of(context).dividerColor.withOpacity(0.1),
          splashColor: Theme.of(context).dividerColor.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: 100.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightOutline
                    : AppColor.darkOutlineCardBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color:
                            context.watch<ThemeBloc>().state == AppTheme.light
                                ? AppColor.lightTertiary
                                : AppColor.darkTertiary,
                      ),
                      child: Icon(icon),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        CupertinoIcons.add,
                        size: 20.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.0),
          hoverColor: Theme.of(context).dividerColor.withOpacity(0.1),
          splashColor: Theme.of(context).dividerColor.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            height: 80.0,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.watch<ThemeBloc>().state == AppTheme.light
                    ? AppColor.lightOutline
                    : AppColor.darkOutlineCardBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color:
                            (context.watch<ThemeBloc>().state == AppTheme.light
                                ? AppColor.lightTertiary
                                : AppColor.darkTertiary),
                      ),
                      child: const Icon(
                        CupertinoIcons.folder,
                        size: 20.0,
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Document title',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: 12.0,
                                  ),
                        ),
                        Row(
                          children: [
                            /// file size
                            Text(
                              '220 KB',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),

                            /// divider
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                '|',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),

                            /// file extension
                            Text(
                              'pdf',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                _buildDocumentActionMenu(),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(
                //     Icons.more_vert_outlined,
                //     size: 20.0,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ContextMenuRegion _buildDocumentActionMenu() {
    return ContextMenuRegion(
      contextMenu: ContextMenu(
        entries: _buildDocumentActionMenuItems(),
      ),
      child: const Icon(
        Icons.more_vert_outlined,
        size: 20.0,
      ),
    );
  }

  List<ContextMenuEntry> _buildDocumentActionMenuItems() {
    return [
      const MenuItem(
          label: 'Preview', icon: CupertinoIcons.eye, value: 'preview'),
      MenuItem.submenu(
        label: 'Download',
        icon: Icons.file_download_outlined,
        items: [
          MenuItem(
            label: 'Pdf',
            icon: CupertinoIcons.doc,
            onSelected: () {},
          ),
          MenuItem(
            label: 'Excel',
            icon: CupertinoIcons.doc_chart,
            onSelected: () {},
          ),
        ],
      ),
    ];
  }
}
