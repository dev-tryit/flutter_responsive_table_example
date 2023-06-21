
import 'package:flutter/material.dart';
import 'package:responsive_table/responsive_table.dart';

class CustomTableDataController {
  ///(모든) 데이터
  List<Map<String, dynamic>> dataList = [];

  ///(모든) (정렬된) 데이터
  String? sortKey;
  String? sortedValue;
  bool isSortAscending = true;

  List<Map<String, dynamic>> get sortedDataList {
    if (sortKey == null) {
      return dataList;
    }

    if (isSortAscending) {
      return [...dataList]
        ..sort((a, b) => b["$sortKey"].compareTo(a["$sortKey"]));
    } else {
      return [...dataList]
        ..sort((a, b) => a["$sortKey"].compareTo(b["$sortKey"]));
    }
  }

  ///(정렬된) (검색된) 데이터
  late String searchKey;
  String? searchValue;
  bool isOpenedSearch = false;

  List<Map<String, dynamic>> get searchedSortedDataList {
    if (searchValue == "" || searchValue == null) {
      return sortedDataList;
    } else {
      return sortedDataList
          .where((data) => data[searchKey]
              .toString()
              .toLowerCase()
              .contains(searchValue.toString().toLowerCase()))
          .toList();
    }
  }

  ///(현재 화면에 보이는) (정렬된) (검샏된) 데이터
  List<Map<String, dynamic>> get displayedFilteredSortedDataList =>
      searchedSortedDataList;

  ///(선택된) 데이터
  List<Map<String, dynamic>> selectedDataList = [];

  bool isLoading = true;

  late void Function(VoidCallback fn) setState;

  CustomTableDataController();

  void init(
      {required void Function(VoidCallback fn) setState,
      required String searchKey}) {
    setRefreshFunction(setState);
    setSearchKey(searchKey);
  }

  void setRefreshFunction(void Function(VoidCallback fn) setState) {
    this.setState = setState;
  }

  void setIsLoading(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }

  void openSearch(bool isOpenedSearch) {
    setState(() {
      this.isOpenedSearch = isOpenedSearch;
    });
  }

  void appendDataList(List<Map<String, dynamic>> dataList) {
    setIsLoading(true);

    this.dataList.addAll(dataList);

    setIsLoading(false);
  }


  void setSearchKey(String searchKey) {
    setIsLoading(true);

    this.searchKey = searchKey;

    setIsLoading(false);
  }

  void setSearchValue(String? searchValue) {
    setIsLoading(true);

    this.searchValue = searchValue;

    setIsLoading(false);

  }

  void setSortKey(String? sortKey) {
    setIsLoading(true);

    if (this.sortKey != sortKey) {
      isSortAscending = true;
      this.sortKey = sortKey;
      setIsLoading(false);
      return;
    }

    if (isSortAscending) {
      isSortAscending = false;
      this.sortKey = sortKey;
      setIsLoading(false);
      return;
    }

    this.sortKey = null;
    setIsLoading(false);
  }
}

class CustomTable extends StatefulWidget {
  final CustomTableDataController controller;

  const CustomTable({Key? key, required this.controller}) : super(key: key);

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  late List<DatatableHeader> _headers;

  @override
  void initState() {
    super.initState();

    widget.controller.init(setState: setState, searchKey: 'id');

    _headers = headers();
  }

  @override
  Widget build(BuildContext context) {
    final source = [...widget.controller.displayedFilteredSortedDataList];
    return ResponsiveDatatable(
      showSelect: true,
      autoHeight: false,
      reponseScreenSizes: [ScreenSize.xs],
      title: title(),
      actions: actions(),
      headers: _headers,
      source: source,
      expanded: List.generate(source.length, (index) => false), //없으면 에러남.
      selecteds: widget.controller.selectedDataList,
      sortColumn: widget.controller.sortKey,
      onSort: (key) {
        widget.controller.setSortKey(key);
      },
      sortAscending: widget.controller.isSortAscending,
      isLoading: widget.controller.isLoading,
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
      // onSelect: (value, item) {
      //   print("$value  $item ");
      //   if (value!) {
      //     setState(() => selectedDataList.add(item));
      //   } else {
      //     setState(
      //             () => selectedDataList.removeAt(selectedDataList.indexOf(item)));
      //   }
      // },
      // onSelectAll: (value) {
      //   if (value!) {
      //     setState(() => selectedDataList = displayedFilteredSortedDataList
      //         .map((entry) => entry)
      //         .toList()
      //         .cast());
      //   } else {
      //     setState(() => selectedDataList.clear());
      //   }
      // },
      // dropContainer: (data) {
      //   if (int.tryParse(data['id'].toString())!.isEven) {
      //     return Text("is Even");
      //   }
      //   return _DropDownContainer(data: data);
      // },
      // onChangedRow: (value, header) {
      //   /// print(value);
      //   /// print(header);
      // },
      // onSubmittedRow: (value, header) {
      //   /// print(value);
      //   /// print(header);
      // },
      // onTabRow: (data) {
      //   print(data);
      // },
    );
  }

  List<Widget> actions() {
    return [
      if (widget.controller.isOpenedSearch)
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                hintText: 'Enter search term based on ' +
                    widget.controller.searchKey
                        .replaceAll(new RegExp('[\\W_]+'), ' ')
                        .toUpperCase(),
                prefixIcon: IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      widget.controller.openSearch(false);
                      widget.controller.setSearchValue(null);
                    }),
                suffixIcon:
                    IconButton(icon: Icon(Icons.search), onPressed: () {})),
            onSubmitted: (value) {
              widget.controller.setSearchValue(value);
            },
          ),
        )
      else
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            widget.controller.openSearch(true);
          },
        )
    ];
  }

  Widget title() {
    return TextButton.icon(
      onPressed: () => {},
      icon: Icon(Icons.add),
      label: Text("new item"),
    );
  }

  List<DatatableHeader> headers() {
    return [
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
        textAlign: TextAlign.center,
      ),
    ];
  }
}
