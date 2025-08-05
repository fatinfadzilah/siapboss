import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:siapbos/api/memoAPI.dart';

Future<void> generatePdf(BuildContext context, String projectName, List<Map<String, dynamic>> memos) async {
  final summary = await MemoApi.generateMemoSummary(memos);

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Memo Report - $projectName', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 16),
        pw.Text('AI Summary:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.Text(summary),
        pw.SizedBox(height: 20),
        pw.Text('All Memos:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ...memos.map((memo) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("• ${memo['nama_aktiviti'] ?? 'Untitled'}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text("  - Tarikh: ${memo['tarikh'] ?? '-'}"),
            pw.Text("  - Masa: ${memo['masa'] ?? '-'}"),
            pw.Text("  - Lokasi: ${memo['lokasi'] ?? '-'}"),
            pw.Text("  - Keterangan: ${memo['keterangan'] ?? '-'}"),
            pw.SizedBox(height: 12),
          ],
        )),
      ],
    ),
  );

  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}
