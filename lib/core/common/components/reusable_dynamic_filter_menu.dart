import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'reusable_popup_menu_container.dart';
import 'custom_dropdown_button.dart';

class ReusableDynamicFilterMenu extends StatefulWidget {
  const ReusableDynamicFilterMenu({super.key});

  @override
  State<ReusableDynamicFilterMenu> createState() =>
      _ReusableDynamicFilterMenuState();
}

class _ReusableDynamicFilterMenuState extends State<ReusableDynamicFilterMenu> {
  @override
  Widget build(BuildContext context) {
    return ReusablePopupMenuContainer(
      icon: FluentIcons.re_order_16_regular,
      width: 300.0,
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 300.0,
            maxHeight: 500.0,
          ),
          decoration: BoxDecoration(
            border:
                Border.all(color: Theme.of(context).dividerColor, width: 0.8),
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                  left: 10.0,
                ),
                child: Text(
                  'Filter conditions:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),


              const Divider(
                thickness: 1.5,
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const Text('View items Where'),
                      CustomDropdownButton(onChanged: (value) {}, label: 'Asset Classification',),
                      // todo: also hidden by default, unless another filter which in this case an asset subclass is selected

                      //CustomDropdownButton(onChanged: (value) {}, label: 'Asset Subclass',),
                    ],
                  ),
                ),
              ),

              const Divider(
                thickness: 1.5,
              ),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.add,
                            size: 16.0,
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            'Add Filter',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // todo: hide by default, only shows up when there's a filter
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Clear filter(s)',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
