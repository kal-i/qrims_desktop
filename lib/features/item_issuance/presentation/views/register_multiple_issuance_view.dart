import 'package:flutter/material.dart';

import '../components/accountable_officer.dart';

class RegisterMultipleIssuanceView extends StatefulWidget {
  const RegisterMultipleIssuanceView({super.key});

  @override
  State<RegisterMultipleIssuanceView> createState() =>
      _RegisterMultipleIssuanceViewState();
}

class _RegisterMultipleIssuanceViewState
    extends State<RegisterMultipleIssuanceView> {
  final ValueNotifier<List<Map<String, dynamic>>> officers = ValueNotifier([
    {
      'officer': {
        'name': 'Liza Sovereign',
        'position': 'Accountant III',
        'office': 'Accounting',
      },
      'items': [
        {'name': 'Air Conditioner'},
        {'name': 'Macbook Air'},
      ],
    },
    {
      'officer': {
        'name': 'Kaii Lee',
        'position': 'Superintendent',
        'office': 'OSDS',
      },
      'items': [
        {'name': 'Air Conditioner'},
        {'name': 'Macbook Air'},
      ],
    },
  ]);

  void _addOfficer() {
    officers.value = [
      ...officers.value,
      {
        'officer': {
          'name': 'New Officer',
          'position': 'New Position',
          'office': 'New Office',
        },
        'items': [
          {'name': 'New Item'}
        ],
      }
    ];
  }

  void _reorderOfficers(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final updated = List<Map<String, dynamic>>.from(officers.value);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    officers.value = updated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            '🧑‍💼 Receiving Officers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 5.0),
          Text(
            'Officers accountable to this issuance.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _addOfficer,
            child: const Text('Add Officer'),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: officers,
              builder: (context, value, _) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return DragTarget<int>(
                      onAccept: (fromIndex) =>
                          _reorderOfficers(fromIndex, index),
                      builder: (context, candidateData, rejectedData) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Draggable<int>(
                            data: index,
                            feedback: SizedBox(
                              width: 250,
                              child: AccountableOfficerCard(
                                officer: value[index],
                                isDragging: true,
                              ),
                            ),
                            childWhenDragging: const SizedBox(width: 250),
                            child: SizedBox(
                              width: 250,
                              child:
                                  AccountableOfficerCard(officer: value[index]),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
