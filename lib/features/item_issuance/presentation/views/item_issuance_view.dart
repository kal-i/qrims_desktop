import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

import '../../../../config/themes/app_color.dart';
import '../../../../config/themes/app_theme.dart';
import '../../../../config/themes/bloc/theme_bloc.dart';
import '../../../../core/common/components/custom_icon_button.dart';
import '../../../../core/common/components/pagination_controls.dart';
import '../../../../core/common/components/reusable_custom_refresh_outline_button.dart';
import '../../../../core/common/components/reusable_filter_custom_outline_button.dart';
import '../../../../core/common/components/search_button/expandable_search_button.dart';
import '../../../auth/presentation/components/custom_outline_button.dart';
import '../../../../core/common/components/custom_data_table.dart';
import '../components/custom_document_preview.dart';
import '../components/custom_interactable_card.dart';
import '../components/document_card.dart';

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
    return Scaffold(
      body: Column(
        children: [
          _buildClickableCardsRow(),
          const SizedBox(
            height: 50.0,
          ),
          _buildRecentlyGeneratedDocumentsRow(),
          const SizedBox(
            height: 50.0,
          ),
          Expanded(
            child: _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableCardsRow() {
    return Row(
      children: [
        Expanded(
          child: CustomInteractableCard(
            name: 'New Issuance',
            icon: CupertinoIcons.folder,
            onTap: () {},
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: CustomInteractableCard(
            name: 'New ICS',
            icon: Icons.note_outlined,
            onTap: () {},
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: CustomInteractableCard(
            name: 'New RIS',
            icon: CupertinoIcons.doc,
            onTap: () => showCustomDocumentPreview(context),
          ),
        ),
        const SizedBox(
          width: 15.0,
        ),
        Expanded(
          child: CustomInteractableCard(
            name: 'New PAR',
            icon: CupertinoIcons.folder,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  // todo: for this, imma fetch few info in the server like the id, file/issuance name, and if possible size
  // this will then make an http req when wanna be previewed
  // every time there is a new issuance, it will first the first 3 item issuance info in the db and paste in here
  // btw let's add an stepper for the status like: prepared a doc for approval - approved/ declined - conclusion if there is like generated
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
        Row(
          children: [
            Expanded(
                child: DocumentCard(
              onTap: () {},
            )),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
                child: DocumentCard(
              onTap: () {},
            )),
            const SizedBox(
              width: 15.0,
            ),
            Expanded(
                child: DocumentCard(
              onTap: () {},
            )),
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
          // _buildReusableTableFilterButton(4, 'Pending'),
          // _buildReusableTableFilterButton(5, 'Approved'),
          // _buildReusableTableFilterButton(6, 'Declined'),
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
        const SizedBox(
          width: 10.0,
        ),
        _buildRefreshButton(),
        const SizedBox(
          width: 10.0,
        ),
        _buildFilterButton(),
        const SizedBox(
          width: 10.0,
        ),
        _buildSortButton(),
      ],
    );
  }

  Widget _buildRefreshButton() {
    return ReusableCustomRefreshOutlineButton(
      onTap: () {},
    );
  }

  Widget _buildFilterButton() {
    return const CustomIconButton(icon: FluentIcons.filter_add_20_regular, isOutlined: true,);
  }

  Widget _buildSortButton() {
    return const CustomIconButton(icon: FluentIcons.text_sort_ascending_20_regular, isOutlined: true,);
  }

  Widget _buildDataTable() {
    return Column(
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
                  id: '1',
                ),
              ],
            ),
            onActionSelected: (index, action) {
              print('row index: $index - $action');
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
          onPageSizeChanged: (int size) {},
        ),
      ],
    );
  }

  // define your context menu entries
  final menus = <ContextMenuEntry>[
    const MenuHeader(text: "Context Menu"),
    MenuItem(
      label: 'Copy',
      icon: Icons.copy,
      onSelected: () {
        // implement copy
      },
    ),
    MenuItem(
      label: 'Paste',
      icon: Icons.paste,
      onSelected: () {
        // implement paste
      },
    ),
    const MenuDivider(),
    MenuItem.submenu(
      label: 'Edit',
      icon: Icons.edit,
      items: [
        MenuItem(
          label: 'Undo',
          value: "Undo",
          icon: Icons.undo,
          onSelected: () {
            // implement undo
          },
        ),
        MenuItem(
          label: 'Redo',
          value: 'Redo',
          icon: Icons.redo,
          onSelected: () {
            // implement redo
          },
        ),
      ],
    ),
  ];
}
