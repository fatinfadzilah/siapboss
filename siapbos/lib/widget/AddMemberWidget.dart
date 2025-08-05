import 'package:flutter/material.dart';
import 'package:siapbos/api/memoAPI.dart';

Future<void> showAddMemberDialog({
  required BuildContext context,
  required List<String> initialMembers,
  required Function(List<String>) onMembersSelected,
}) async {
  List<String> staffNames = [];
  List<String> tempSelected = List.from(initialMembers);
  String searchQuery = '';
  bool isLoading = true;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          // Load staff only once when dialog is first shown
          if (isLoading) {
            MemoApi.getStaffMembers().then((names) {
              staffNames = names;
              isLoading = false;
              setModalState(() {});
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to load staff members')),
              );
              isLoading = false;
              setModalState(() {});
            });
          }

          final filteredNames = staffNames
              .where((name) => name.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Select Staff'),
            content: SizedBox(
              width: double.maxFinite,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search staff',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          onChanged: (value) {
                            setModalState(() => searchQuery = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: Scrollbar(
                            child: ListView.builder(
                              itemCount: filteredNames.length,
                              itemBuilder: (_, index) {
                                final name = filteredNames[index];
                                return CheckboxListTile(
                                  title: Text(name),
                                  value: tempSelected.contains(name),
                                  onChanged: (bool? selected) {
                                    setModalState(() {
                                      if (selected == true) {
                                        tempSelected.add(name);
                                      } else {
                                        tempSelected.remove(name);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  onMembersSelected(tempSelected);
                  Navigator.pop(context);
                },
                child: Text('Done (${tempSelected.length})'),
              ),
            ],
          );
        },
      );
    },
  );
}
