import 'dart:math';

import 'package:flutter/material.dart';
import 'package:responsive_table/responsive_table.dart';

class ExampleTable extends StatefulWidget {
  const ExampleTable({Key? key}) : super(key: key);

  @override
  State<ExampleTable> createState() => _ExampleTableState();
}

class _ExampleTableState extends State<ExampleTable> {
  List<Map<String, dynamic>> _sourceOriginal = [];
  List<Map<String, dynamic>> _sourceFiltered = [];
  List<Map<String, dynamic>> _source = [];
  List<Map<String, dynamic>> _selecteds = [];

  var random = new Random();

  //private
  late List<DatatableHeader> _headers;
  String? _sortColumn;
  List<int> _perPages = [10, 20, 50, 100];

  // List<bool>? _expanded;
  int _currentPage = 1;
  bool _isSearch = false;
  int _total = 100;
  int? _currentPerPage = 10;
  bool _sortAscending = true;
  bool _isLoading = true;
  bool _showSelect = true;
  String? _searchKey = "id";

  List<Map<String, dynamic>> _generateData({int n = 100}) {
    return List.generate(
      n,
      (i) => {
        "id": i,
        "sku": "$i\000$i",
        "name": "Product $i",
        "category": "Category-$i",
        "price": i * 10.00,
        "cost": "20.00",
        "margin": "${i}0.20",
        "in_stock": "${i}0",
        "alert": "5",
        "received": [i + 20, 150]
      },
    );
  }

  _initializeData() async {
    _initData();
  }

  _initData() async {
    // _expanded = List.generate(_currentPerPage!, (index) => false);

    setState(() => _isLoading = true);
    Future.delayed(Duration(seconds: 3)).then((value) {
      _sourceOriginal.clear();
      _sourceOriginal.addAll(_generateData(n: random.nextInt(10000)));
      _sourceFiltered = _sourceOriginal;
      _total = _sourceFiltered.length;
      _source = _sourceFiltered.getRange(0, _currentPerPage!).toList();
      setState(() => _isLoading = false);
    });
  }

  _getData({int startOffset = 0}) async {
    setState(() => _isLoading = true);
    int _expandedLen = (_total - startOffset < _currentPerPage!
            ? _total - startOffset
            : _currentPerPage) ??
        0;
    Future.delayed(Duration(seconds: 0)).then((value) {
      // _expanded = List.generate(_expandedLen as int, (index) => false);
      _source.clear();
      _source = _sourceFiltered
          .getRange(startOffset, startOffset + _expandedLen)
          .toList();
      setState(() => _isLoading = false);
    });
  }

  _filterData(value) {
    setState(() => _isLoading = true);

    try {
      if (value == "" || value == null) {
        _sourceFiltered = _sourceOriginal;
      } else {
        _sourceFiltered = _sourceOriginal
            .where((data) => data[_searchKey!]
                .toString()
                .toLowerCase()
                .contains(value.toString().toLowerCase()))
            .toList();
      }

      _total = _sourceFiltered.length;
      var _rangeTop = _total < _currentPerPage! ? _total : _currentPerPage!;
      // _expanded = List.generate(_rangeTop, (index) => false);
      _source = _sourceFiltered.getRange(0, _rangeTop).toList();
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();

    /// set headers
    _headers = [
      DatatableHeader(
          text: "ID",
          value: "id",
          show: true,
          sortable: true,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Name",
          value: "name",
          show: true,
          flex: 2,
          sortable: true,
          editable: true,
          textAlign: TextAlign.left),
      DatatableHeader(
          text: "SKU",
          value: "sku",
          show: true,
          sortable: true,
          textAlign: TextAlign.center),
      DatatableHeader(
          text: "Category",
          value: "category",
          show: true,
          sortable: true,
          textAlign: TextAlign.left),
      DatatableHeader(
          text: "Price",
          value: "price",
          show: true,
          sortable: true,
          textAlign: TextAlign.left),
      DatatableHeader(
          text: "Margin",
          value: "margin",
          show: true,
          sortable: true,
          textAlign: TextAlign.left),
      DatatableHeader(
          text: "In Stock",
          value: "in_stock",
          show: true,
          sortable: true,
          textAlign: TextAlign.left),
      DatatableHeader(
          text: "Alert",
          value: "alert",
          show: true,
          sortable: true,
          textAlign: TextAlign.left),
      DatatableHeader(
          text: "Received",
          value: "received",
          show: true,
          sortable: false,
          sourceBuilder: (value, row) {
            List list = List.from(value);
            return Container(
              child: Column(
                children: [
                  Container(
                    width: 85,
                    child: LinearProgressIndicator(
                      value: list.first / list.last,
                    ),
                  ),
                  Text("${list.first} of ${list.last}")
                ],
              ),
            );
          },
          textAlign: TextAlign.center),
    ];

    _initializeData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDatatable(
      title: TextButton.icon(
        onPressed: () => {},
        icon: Icon(Icons.add),
        label: Text("new item"),
      ),
      reponseScreenSizes: [ScreenSize.xs],
      actions: [
        if (_isSearch)
          Expanded(
              child: TextField(
            decoration: InputDecoration(
                hintText: 'Enter search term based on ' +
                    _searchKey!
                        .replaceAll(new RegExp('[\\W_]+'), ' ')
                        .toUpperCase(),
                prefixIcon: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      setState(() {
                        _isSearch = false;
                      });
                      _initializeData();
                    }),
                suffixIcon:
                    IconButton(icon: Icon(Icons.search), onPressed: () {})),
            onSubmitted: (value) {
              _filterData(value);
            },
          )),
        if (!_isSearch)
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearch = true;
                });
              })
      ],
      headers: _headers,
      source: _source,
      selecteds: _selecteds,
      showSelect: _showSelect,
      autoHeight: false,
      dropContainer: (data) {
        if (int.tryParse(data['id'].toString())!.isEven) {
          return Text("is Even");
        }
        return _DropDownContainer(data: data);
      },
      onChangedRow: (value, header) {
        /// print(value);
        /// print(header);
      },
      onSubmittedRow: (value, header) {
        /// print(value);
        /// print(header);
      },
      onTabRow: (data) {
        print(data);
      },
      onSort: (value) {
        setState(() => _isLoading = true);

        setState(() {
          _sortColumn = value;
          _sortAscending = !_sortAscending;
          if (_sortAscending) {
            _sourceFiltered
                .sort((a, b) => b["$_sortColumn"].compareTo(a["$_sortColumn"]));
          } else {
            _sourceFiltered
                .sort((a, b) => a["$_sortColumn"].compareTo(b["$_sortColumn"]));
          }
          var _rangeTop = _currentPerPage! < _sourceFiltered.length
              ? _currentPerPage!
              : _sourceFiltered.length;
          _source = _sourceFiltered.getRange(0, _rangeTop).toList();
          _searchKey = value;

          _isLoading = false;
        });
      },
      // expanded: _expanded,
      sortAscending: _sortAscending,
      sortColumn: _sortColumn,
      isLoading: _isLoading,
      onSelect: (value, item) {
        print("$value  $item ");
        if (value!) {
          setState(() => _selecteds.add(item));
        } else {
          setState(() => _selecteds.removeAt(_selecteds.indexOf(item)));
        }
      },
      onSelectAll: (value) {
        if (value!) {
          setState(
              () => _selecteds = _source.map((entry) => entry).toList().cast());
        } else {
          setState(() => _selecteds.clear());
        }
      },
      footers: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Rows per page:"),
        ),
        if (_perPages.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: DropdownButton<int>(
              value: _currentPerPage,
              items: _perPages
                  .map((e) => DropdownMenuItem<int>(
                        child: Text("$e"),
                        value: e,
                      ))
                  .toList(),
              onChanged: (dynamic value) {
                setState(() {
                  _currentPerPage = value;
                  _currentPage = 1;
                  _getData();
                });
              },
              isExpanded: false,
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("$_currentPage - $_currentPerPage of $_total"),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 16,
          ),
          onPressed: _currentPage == 1
              ? null
              : () {
                  var _nextSet = _currentPage - _currentPerPage!;
                  setState(() {
                    _currentPage = _nextSet > 1 ? _nextSet : 1;
                    _getData(startOffset: _currentPage - 1);
                  });
                },
          padding: EdgeInsets.symmetric(horizontal: 15),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: _currentPage + _currentPerPage! - 1 > _total
              ? null
              : () {
                  var _nextSet = _currentPage + _currentPerPage!;

                  setState(() {
                    _currentPage = _nextSet < _total
                        ? _nextSet
                        : _total - _currentPerPage!;
                    _getData(startOffset: _nextSet - 1);
                  });
                },
          padding: EdgeInsets.symmetric(horizontal: 15),
        )
      ],
      headerDecoration: BoxDecoration(
          color: Colors.grey,
          border: Border(bottom: BorderSide(color: Colors.red, width: 1))),
      selectedDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[300]!, width: 1)),
        color: Colors.green,
      ),
      headerTextStyle: TextStyle(color: Colors.white),
      rowTextStyle: TextStyle(color: Colors.green),
      selectedTextStyle: TextStyle(color: Colors.white),
    );
  }
}

class _DropDownContainer extends StatelessWidget {
  final Map<String, dynamic> data;

  const _DropDownContainer({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> _children = data.entries.map<Widget>((entry) {
      Widget w = Row(
        children: [
          Text(entry.key.toString()),
          Spacer(),
          Text(entry.value.toString()),
        ],
      );
      return w;
    }).toList();

    return Container(
      /// height: 100,
      child: Column(
        /// children: [
        ///   Expanded(
        ///       child: Container(
        ///     color: Colors.red,
        ///     height: 50,
        ///   )),
        /// ],
        children: _children,
      ),
    );
  }
}
