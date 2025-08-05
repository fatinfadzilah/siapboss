import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:siapbos/utils/color_utils.dart';

class MemoCardWidget extends StatelessWidget {
  final Map<String, dynamic> memo;
  final VoidCallback? onTap;

  const MemoCardWidget({super.key, required this.memo, this.onTap});

  @override
  Widget build(BuildContext context) {
    final rawDate = memo['tarikh'];
    final date = (rawDate is String && rawDate.isNotEmpty)
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(rawDate))
        : '';
    final time = (memo['masa'] as String?)?.substring(0, 5) ?? '';
    final location = memo['lokasi'] ?? '-';
    final members = List<String>.from(memo['members'] ?? []);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: getColorForMemo(location),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(memo['nama_aktiviti'] ?? 'No Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
                  SizedBox(width: 6),
                  Text('$date | $time'),
                ],
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                  SizedBox(width: 6),
                  Expanded(child: Text(location, softWrap: true)),
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: members.map((name) {
                  return Chip(
                    label: Text(name, style: TextStyle(fontSize: 12)),
                    avatar: CircleAvatar(
                      child: Text(_getInitials(name)),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  );
                }).toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
