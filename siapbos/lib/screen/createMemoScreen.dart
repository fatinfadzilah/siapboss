
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:siapbos/api/memoAPI.dart';
import 'package:siapbos/provider/authProvider.dart';
import 'package:siapbos/screen/MapScreen.dart';
import 'package:siapbos/widget/AddMemberWidget.dart';

  class createMemoScreen extends StatefulWidget {
    final String projectName;
    final bool isEdit;
    final Map<String, dynamic>? existingMemo;

    const createMemoScreen({
      super.key,
      required this.projectName,
      this.isEdit = false,
      this.existingMemo,
    });

    @override
    State<createMemoScreen> createState() => _createMemoScreenState();
  }

    class _createMemoScreenState extends State<createMemoScreen> {
      final _formKey = GlobalKey<FormState>();
      String? locationError;
      final titleController = TextEditingController();
      final descController = TextEditingController();
      DateTime? currentDate;
      TimeOfDay? selectedTime;
      String? location;
      List<String> members = [];
      double? _selectedLat;
      double? _selectedLng;
      MapController mapController = MapController();
      LatLng _initialLocation = const LatLng(1.5466496, 103.7172736);
      List<Marker> markers = [];
      List<Map<String, dynamic>> projectList = [];
      final TextEditingController locationController = TextEditingController();
      
      int? selectedProjectId;
      bool isLoadingProjects = true;


      @override
      void initState() {
        super.initState();
        loadProjects();

        if (widget.isEdit && widget.existingMemo != null) {
          titleController.text = widget.existingMemo!['nama_aktiviti'] ?? '';
          descController.text = widget.existingMemo!['keterangan'] ?? '';

          final rawMembers = widget.existingMemo!['members'];
          if (rawMembers is String) {
            members = List<String>.from(jsonDecode(rawMembers));
          } else if (rawMembers is List) {
            members = List<String>.from(rawMembers);
          }

          if (widget.existingMemo!['tarikh'] != null) {
            currentDate = DateTime.tryParse(widget.existingMemo!['tarikh']);
          }

          if (widget.existingMemo!['masa'] != null) {
            final timeParts = widget.existingMemo!['masa'].split(":");
            if (timeParts.length >= 2) {
              selectedTime = TimeOfDay(
                hour: int.parse(timeParts[0]),
                minute: int.parse(timeParts[1]),
              );
            }
          }

          location = widget.existingMemo!['lokasi'];
          locationController.text = location ?? '';

          final rawLat = widget.existingMemo!['lat'];
          final rawLng = widget.existingMemo!['lng'];

          if (rawLat is String) {
            _selectedLat = double.tryParse(rawLat);
          } else if (rawLat is double) {
            _selectedLat = rawLat;
          }

          if (rawLng is String) {
            _selectedLng = double.tryParse(rawLng);
          } else if (rawLng is double) {
            _selectedLng = rawLng;
          }

          if (_selectedLat != null && _selectedLng != null) {
            _initialLocation = LatLng(_selectedLat!, _selectedLng!);
            markers = [
              Marker(
                point: _initialLocation,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_pin, color: Colors.red),
              ),
            ];
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {}); 
          });
        }
      }

      void loadProjects() async {
      final result = await MemoApi.getProjects();
      if (!mounted) return;

      int? projectIdToSet;

      if (widget.isEdit && widget.existingMemo != null) {
         print('existingMemo: ${widget.existingMemo}'); // 👈 tambah
        final rawProjectId = widget.existingMemo!['project_id'];
        if (rawProjectId is String) {
          projectIdToSet = int.tryParse(rawProjectId);
        } else if (rawProjectId is int) {
          projectIdToSet = rawProjectId;
        }
      } else if (result.isNotEmpty) {
        final firstId = result.first['id'];
        projectIdToSet = firstId is String ? int.tryParse(firstId) : firstId;
      }

      final cleanedList = result.map((project) {
      final rawId = project['id'];
      final id = rawId is String ? int.tryParse(rawId) : rawId;
      return {
        'id': id,
        'name': project['name'],
        'lokasi': project['lokasi'],
      };
    }).where((proj) => proj['id'] != null).toList();

       print('selectedProjectId: $selectedProjectId');
       print('Available ddIDs: ${cleanedList.map((e) => e['id']).toList()}');
      setState(() {
        projectList = cleanedList;
        isLoadingProjects = false;
        selectedProjectId = projectIdToSet;
      });
    }

      @override
      Widget build(BuildContext context) {
        return Scaffold( 
          backgroundColor: const Color.fromARGB(255, 241, 241, 241),
          appBar: AppBar( backgroundColor: Colors.white,
            title: Text(
              widget.isEdit ? "Edit Memo" : "Create New Memo",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 16, 55, 123),
              ),
            ),
          ),
          body: Stack(
            children: [
             Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/background.png',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Column(
                      children: [
                        Card(color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                SizedBox(height: 8),
                                Visibility(
                                    visible: !isLoadingProjects,
                                    child: DropdownButtonFormField<int>(
                                      value: selectedProjectId,
                                      decoration: const InputDecoration(
                                        labelText: 'Select Project',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                                        ),
                                      ),
                                      items: projectList.map((project) {
                                        return DropdownMenuItem<int>(
                                          value: project['id'],
                                          child: Text(project['name'] ?? 'Unnamed Project'),
                                        );
                                      }).toList(),
                                      
                                      onChanged: (value) {
                                        setState(() {
                                          selectedProjectId = value;
                                        });
                                      },
                                      validator: (value) =>
                                          value == null ? 'Please select a project' : null,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  TextFormField(
                                    controller: titleController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter task title',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Color(0xFF3B62FF)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your title';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                    Expanded(
                                        child: FormField<DateTime>(
                                          validator: (value) {
                                            if (currentDate == null) {
                                              return 'Date required';
                                            }
                                            return null;
                                          },
                                          builder: (FormFieldState<DateTime> state) {
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    await _pickDueDate();
                                                    state.didChange(currentDate); 
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: state.hasError ? Colors.red : Colors.grey.shade400,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          currentDate == null
                                                              ? 'Select date'
                                                              : '${currentDate!.day}/${currentDate!.month}/${currentDate!.year}',
                                                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                                                        ),
                                                        const Icon(Icons.calendar_today, size: 18, color: Color.fromARGB(255, 16, 55, 123)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (state.hasError)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 6, left: 8),
                                                    child: Text(
                                                      state.errorText!,
                                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                          child: FormField<TimeOfDay>(
                                            validator: (value) {
                                              if (selectedTime == null) {
                                                return 'Time required';
                                              }
                                              return null;
                                            },
                                            builder: (FormFieldState<TimeOfDay> state) {
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      await _pickTime();
                                                      state.didChange(selectedTime); 
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: state.hasError ? Colors.red : Colors.grey.shade400,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            selectedTime == null
                                                                ? 'Select time'
                                                                : selectedTime!.format(context),
                                                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                                                          ),
                                                          const Icon(Icons.access_time, size: 18, color: Color.fromARGB(255, 16, 55, 123)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (state.hasError)
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 6, left: 8),
                                                      child: Text(
                                                        state.errorText!,
                                                        style: const TextStyle(color: Colors.red, fontSize: 12),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  TextFormField(
                                    maxLines: 3,
                                    controller: descController,
                                    decoration: InputDecoration(
                                      labelText: 'Describe the task',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Color(0xFF3B62FF)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade400),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text('*Please be specific and details on your memo.',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  _buildLocation(),
                                  SizedBox(height: 15),
                                  Text('Staff Involved',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                                  FormField<List<String>>(
                                  validator: (value) {
                                    if (members.isEmpty) {
                                      return 'At least one member is required';
                                    }
                                    return null;
                                  },
                                  builder: (FormFieldState<List<String>> state) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            ...members.map((member) {
                                              return Chip(
                                                avatar: CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  child: Text(
                                                    _getInitials(member),
                                                    style: TextStyle(
                                                      color: Colors.blue.shade900,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                label: Text(member),
                                                onDeleted: () {
                                                  setState(() {
                                                    members.remove(member);
                                                  });
                                                  state.didChange(members); 
                                                },
                                              );
                                            }).toList(),
                                            ActionChip(backgroundColor: const Color.fromARGB(166, 208, 229, 249),
                                              avatar: const Icon(Icons.person_add, size: 20,color: Color.fromARGB(255, 16, 55, 123),),
                                              label: const Text("Add Member"),
                                              onPressed: () async {
                                                showAddMemberDialog(
                                                    context: context,
                                                    initialMembers: members,
                                                    onMembersSelected: (selectedMembers) {
                                                      setState(() {
                                                        members = selectedMembers;
                                                      });
                                                    },
                                                  );
                                              },
                                            ),
                                          ],
                                        ),
                                        if (state.hasError)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 6, left: 8),
                                            child: Text(
                                              state.errorText!,
                                              style: const TextStyle(color: Colors.red, fontSize: 12),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
              
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: SizedBox(
                            width: 360,
                            child:ElevatedButton.icon(
                              onPressed: _submitForm,
                              label: Text(
                                widget.isEdit ? 'Update' : 'Create',
                                style: TextStyle(color: Colors.white),
                              ),
                              icon: Icon(Icons.save, color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 16, 55, 123),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      void _submitForm() async {
        final isFormValid = _formKey.currentState!.validate();
        if (_selectedLat == null || _selectedLng == null) {
          setState(() {
            locationError = 'Location required';
          });
        } else {
          setState(() {
            locationError = null;
          });
      }

      if (isFormValid && locationError == null) {
        final auth = Provider.of<AuthState>(context, listen: false);
        final userId = auth.userId;

        final memoData = {
          'project_id': selectedProjectId,
          'nama_aktiviti': titleController.text,
          'keterangan': descController.text,
          'tarikh': currentDate?.toIso8601String().split('T')[0] ?? '',
          'masa': selectedTime != null
              ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
              : null,
          'lokasi': location ?? '',
          'members': members,
          'lat': _selectedLat ?? '',
          'lng': _selectedLng ?? '',
          'project_name': widget.projectName,
          'created_by': userId,
        };

        try {
          if (widget.isEdit && widget.existingMemo != null) {
            await MemoApi.updateMemo(widget.existingMemo!['id'], memoData);
          } else {
            await MemoApi.createMemo(memoData);
          }
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save memo')),
          );
        }
      }
    }

      Widget _buildLocation() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );

              if (result != null) {
                setState(() {
                  location = result['address'];
                  locationController.text = location!;
                  _selectedLat = result['lat'];
                  _selectedLng = result['lng'];
                  _initialLocation = LatLng(_selectedLat!, _selectedLng!);
                  markers = [
                    Marker(
                      point: _initialLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_pin, color: Colors.red),
                    ),
                  ];
                  locationError = null; 
                });
              }
            },
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(
                  color: locationError != null ? Colors.red : Colors.grey.shade400,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: (_selectedLat != null && _selectedLng != null)
                  ? FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: _initialLocation,
                        initialZoom: 13.0,
                        interactionOptions:
                            const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: "com.hackathon.siapbos",
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, size: 40, color: Color.fromARGB(255, 16, 55, 123)),
                          const SizedBox(height: 8),
                          Text(
                            location != null ? location! : "Tap to select location",
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (locationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10),
              child: Text(
                locationError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      );
    }

      Future<void> _pickDueDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 2),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Color(0xFFF0F6FF), 
              colorScheme: ColorScheme.light(
                primary: Color(0xFF10377B), 
                onPrimary: Colors.white,  
                onSurface: Colors.black87, 
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF10377B), 
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() => currentDate = picked);
      }
    }

      Future<void> _pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              // 🎨 Tukar warna latar belakang dialog
              dialogBackgroundColor: Color(0xFFF0F6FF),
              timePickerTheme: TimePickerThemeData(
                backgroundColor: Color(0xFFF0F6FF), 
                hourMinuteColor: Color(0xFFE3EDF7), 
                hourMinuteTextColor: Colors.black,
                dayPeriodColor: Color(0xFFE3EDF7),
                dialHandColor: Color(0xFF10377B),
                dialBackgroundColor: Colors.white,
                entryModeIconColor: Color(0xFF10377B),
              ),
              colorScheme: ColorScheme.light(
                primary: Color(0xFF10377B),   
                onPrimary: Colors.white,     
                onSurface: Colors.black87,  
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF10377B), 
                ),
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        setState(() => selectedTime = picked);
      }
    }

      String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

}
