import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfOlustur {
  static Future<void> olusturPdf({
    required List<String> aylar,
    required List<String> basliklar,
    required List<List<String>> veriler,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(1),
                child: pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.SizedBox(
                          height:
                              18, // Increase row height for better vertical alignment
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Center(
                              child: pw.Text(
                                'Aylar',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.normal,
                                  fontSize: 4, // Adjust font size as needed
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...basliklar.map((header) {
                          return pw.SizedBox(
                            height:
                                18, // Increase row height for better vertical alignment
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(1),
                              child: pw.Center(
                                child: pw.Text(
                                  replaceTurkishChars(header),
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.normal,
                                    fontSize: 4, // Adjust font size as needed
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    for (int i = 0; i < 13; i++)
                      pw.TableRow(
                        children: [
                          pw.SizedBox(
                            height:
                                18, // Increase row height for better vertical alignment
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.all(1),
                              child: pw.Center(
                                child: pw.Text(
                                  replaceTurkishChars(aylar[i + 1]),
                                  style: const pw.TextStyle(
                                    fontSize: 4.5, // Adjust font size as needed
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(
                            basliklar.length,
                            (j) => pw.SizedBox(
                              height:
                                  18, // Increase row height for better vertical alignment
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(1),
                                child: pw.Center(
                                  child: pw.Text(
                                    veriler[j][i],
                                    style: const pw.TextStyle(
                                      fontSize: 5, // Adjust font size as needed
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/tablo.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(filePath)], text: 'PDF Paylaş'),
    );
  }

  static String replaceTurkishChars(String input) {
    return input
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('Ş', 'S')
        .replaceAll('ş', 's')
        .replaceAll('Ç', 'C')
        .replaceAll('ç', 'c')
        .replaceAll('Ğ', 'G')
        .replaceAll('ğ', 'g')
        .replaceAll('Ö', 'O')
        .replaceAll('ö', 'o')
        .replaceAll('Ü', 'U')
        .replaceAll('ü', 'u');
  }
}
