import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:pks_sem5_p8/components/search_preview.dart';
import 'package:pks_sem5_p8/main.dart';
import 'package:pks_sem5_p8/models/search_result.dart';
import 'package:pks_sem5_p8/models/shop_item.dart';
import 'package:pks_sem5_p8/models/sort_menu_item.dart';
import 'item_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    simpleSearchAndSortAndFilter();
  }

  final searchController = TextEditingController();
  List<SearchResult> searchResults = [];
  List<String> SortOrderingItems = ["По возрастанию", "По убыванию"];
  List<SortMenuItem> SortMenuItems = [
    new SortMenuItem(null, "Нет"),
    new SortMenuItem((item) => item.Name, "Имя"),
    new SortMenuItem((item) => item.PriceRubles, "Цена"),
  ];
  SortMenuItem? selectedSortMenuItem;
  int selectedOrderingMultiplier = 1;

  RangeValues priceFilter = RangeValues(0, 2000);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Поиск"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  simpleSearchAndSortAndFilter();
                });
              },
              decoration:
                  InputDecoration(hintText: "Начните вводить название..."),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Сортировка:",
              style: TextStyle(fontSize: 18),
            ),
            DropdownFlutter(
              items: SortMenuItems,
              initialItem: SortMenuItems[0],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedSortMenuItem = value;
                });
                simpleSearchAndSortAndFilter();
              },
              decoration: CustomDropdownDecoration(
                closedFillColor: Theme.of(context).canvasColor,
                expandedFillColor: Theme.of(context).canvasColor,
              ),
            ),
            DropdownFlutter(
              items: SortOrderingItems,
              initialItem: SortOrderingItems[0],
              onChanged: (value) {
                setState(() {
                  if (value == "По возрастанию") {
                    selectedOrderingMultiplier = 1;
                  } else if (value == "По убыванию") {
                    selectedOrderingMultiplier = -1;
                  }
                });
                simpleSearchAndSortAndFilter();
              },
              decoration: CustomDropdownDecoration(
                closedFillColor: Theme.of(context).canvasColor,
                expandedFillColor: Theme.of(context).canvasColor,
              ),
            ),
            Text(
              "Цена",
              style: TextStyle(fontSize: 18),
            ),
            RangeSlider(
              values: priceFilter,
              min: 0,
              max: 2000,
              divisions: 20,
              onChanged: (RangeValues value) {
                if (value.start == value.end) return;
                setState(() {
                  priceFilter = value;
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  simpleSearchAndSortAndFilter();
                });
              },
              labels: RangeLabels(priceFilter.start.round().toString(),
                  priceFilter.end.round().toString()),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, childAspectRatio: 41 / 40),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  itemCount: searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    final itemKey = GlobalKey();
                    return GestureDetector(
                      key: itemKey,
                      child: SearchPreview(
                        searchResult: searchResults[index],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ItemView(
                                    shopItem: appData.shopItems[
                                        searchResults[index].itemIndex])));
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void simpleSearchAndSortAndFilter() async {
    searchResults.clear();
    await appData.fetchAllData();

    final query = searchController.text.toLowerCase();
    //if (query.isEmpty) return;
    for (int i = 0; i < appData.shopItems.length; i++) {
      final item = appData.shopItems[i];
      final title = item.Name.toLowerCase();
      final start_query_index_title = title.indexOf(query);
      if (start_query_index_title != -1 &&
          item.PriceRubles >= priceFilter.start &&
          item.PriceRubles <= priceFilter.end) {
        setState(() {
          searchResults
              .add(SearchResult(i, query, start_query_index_title, item.Name));
        });
      }
    }
    if (selectedSortMenuItem != null &&
        selectedSortMenuItem!.getSortParameter != null) {
      searchResults.sort((a, b) {
        var getSortParameterFromA = selectedSortMenuItem!
            .getSortParameter!(appData.shopItems[a.itemIndex]);
        var getSortParameterFromB = selectedSortMenuItem!
            .getSortParameter!(appData.shopItems[b.itemIndex]);
        return selectedOrderingMultiplier *
            getSortParameterFromA.compareTo(getSortParameterFromB);
      });
    }
  }
}
