import 'package:app/Screens/anaekran_bilesenler/veriler/degiskenler.dart';
import 'package:flutter/material.dart';

class DynamicTable extends StatefulWidget {
  final int sutunsayisi;

  final List<String> aylar;
  final List<String> basliklar;
  final List<List<String>> veriler;

  const DynamicTable({
    super.key,
    required this.sutunsayisi,
    required this.aylar,
    required this.basliklar,
    required this.veriler,
  });

  @override
  State<DynamicTable> createState() => _DynamicTableState();
}

class _DynamicTableState extends State<DynamicTable> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 10, bottom: 5, right: 8),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Table(
                        border: TableBorder.all(color: Colors.white),
                        children: [
                          for (int i = 0; i < widget.aylar.length; i++)
                            TableRow(
                              children: [
                                TableCell(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          i.isEven
                                              ? Renk.pastelKoyuMavi.withValues(
                                                alpha: 0.06,
                                              )
                                              : Colors.white,
                                    ),
                                    height: 45,
                                    alignment: Alignment.center,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.aylar[i],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Renk.pastelKoyuMavi,
                                          fontWeight: FontWeight.w500,
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width:
                                  widget.sutunsayisi * 100.0, // Kolon genişliği
                              child: Table(
                                border: TableBorder.all(color: Colors.white),
                                children: [
                                  TableRow(
                                    children: [
                                      for (
                                        int i = 0;
                                        i < widget.sutunsayisi;
                                        i++
                                      )
                                        TableCell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Renk.pastelKoyuMavi
                                                  .withValues(alpha: 0.06),
                                            ),
                                            height: 45,
                                            alignment: Alignment.center,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 5,
                                                  right: 5,
                                                ),
                                                child: Text(
                                                  widget.basliklar[i],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Renk.pastelKoyuMavi,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
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
                            SizedBox(
                              width: widget.sutunsayisi * 100.0,
                              child: Table(
                                border: TableBorder.all(color: Colors.white),
                                children: List.generate(
                                  13,
                                  (index) => TableRow(
                                    decoration: BoxDecoration(
                                      color:
                                          index.isEven
                                              ? const Color.fromARGB(
                                                255,
                                                255,
                                                255,
                                                255,
                                              )
                                              : Renk.pastelKoyuMavi.withValues(
                                                alpha: 0.06,
                                              ),
                                    ),
                                    children: List.generate(
                                      widget.sutunsayisi,
                                      (index2) => TableCell(
                                        child: SizedBox(
                                          height: 45,
                                          child: Center(
                                            child: Text(
                                              widget.veriler[index2][index],
                                              style: const TextStyle(
                                                color: Color.fromARGB(
                                                  255,
                                                  30,
                                                  30,
                                                  30,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
