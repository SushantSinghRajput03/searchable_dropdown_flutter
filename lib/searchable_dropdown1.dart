import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchableDropdownApp extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<SearchableDropdownApp> {
  Map<String, String> selectedValueMap = Map();

  // ignore: deprecated_member_use
  List filteredData = List();

  // ignore: deprecated_member_use
  List filteredDataAll = List();
  // ignore: deprecated_member_use
  List alldata = List();

  @override
  void initState() {
    // selectedValueMap["local"] = null;
    selectedValueMap["server"] = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Searchable Dropdown Example App'),
        ),
        body: FutureBuilder(
          // get data from server and return a list of mapped 'name' fields
          future:
              getServerData(), //sets getServerData method as the expected Future
          // ignore: missing_return
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // print('ye hai snapshot.data ka data getSearchableDropdown ke pehle');
              // print(snapshot.data);
              // ignore: deprecated_member_use
              List<String> countries = new List();
              for (int i = 0; i < snapshot.data.length; i++) {
                if (!countries.contains(snapshot.data[i]['region']))
                  countries.add(snapshot.data[i]['region']);
              }

              alldata = snapshot.data;
              // print('alldata ka data ');
              // print(alldata);

              //checks if response returned valid data
              // use mapped 'name' fields for providing options and store selected value to the key "server"
              return getSearchableDropdown(countries, "server", alldata);
            } else if (snapshot.hasError) {
              //checks if the response threw error
              return Text("${snapshot.error}");
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget getSearchableDropdown(List<String> listData, mapKey, alldata) {
    List<DropdownMenuItem> items = [];
    // print('ye hai getSearchableDropdown ka listData ka data');
    // print(listData);
    // print('ye hai getSearchableDropdown ka mapKey ka data');
    // print(mapKey);
    // print('ye hai getSearchableDropdown ka alldata ka data');
    // print(alldata);
    for (int i = 0; i < listData.length; i++) {
      items.add(new DropdownMenuItem(
        child: new Text(
          listData[i],
        ),
        value: listData[i],
      ));
    }
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SearchableDropdown(
              isExpanded: true,
              style: TextStyle(color: Colors.red),
              items: items,
              value: selectedValueMap[mapKey],
              isCaseSensitiveSearch: false,
              hint: new Text('Select Country'),
              searchHint: new Text(
                'Select Country',
                style: new TextStyle(fontSize: 20),
              ),
              onChanged: (value) {
                setState(() {
                  selectedValueMap[mapKey] = value;
                  print('selectedValueMap[mapKey]');
                  print(selectedValueMap[mapKey]);

                  // ignore: deprecated_member_use
                  filteredData = new List();
                  for (int i = 0; i < alldata.length; i++) {
                    if (alldata[i]['region'] == selectedValueMap[mapKey])
                      filteredData.add(alldata[i]);
                  }

                  filteredDataAll = filteredData.toList();
                  print('filteredDataAll ka data');
                  // print(filteredDataAll);
                });
              },
            ),
            Text(selectedValueMap[mapKey].toString()),
            Text('data'),
            // Card(child: Text(filteredData.toString())),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: filteredDataAll.length,
                  itemBuilder: (context, index) {
                    // print('filteredDataAll[index]');
                    // print(filteredDataAll[index]);

                    return SingleChildScrollView(
                      child: Card(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(filteredDataAll[index].toString()),
                            // Text(filteredDataAll.toString()),
                          ],
                        ),
                      )),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
    // ListView.builder(
    //     itemCount: alldata.length,
    //     itemBuilder: (context, index) {
    //       var alldatain1 = alldata[index];
    //       return Text(alldatain1[index].name);
    //     }),
    //  ;
  }

  Future<List> getServerData() async {
    String url =
        'https://restcountries.eu/rest/v2/all?fields=name;capital;alpha3Code;region;population;';
    final response =
        await http.get(url, headers: {"Accept": "application/json"});

    if (response.statusCode == 200) {
      // print(response.body);
      List<dynamic> responseBody = json.decode(response.body);
      // ignore: deprecated_member_use
      // List<String> countries = new List();
      // for (int i = 0; i < responseBody.length; i++) {
      //   countries.add(responseBody[i]['capital']);
      // }
      return responseBody;
    } else {
      print("error from server : $response");
      throw Exception('Failed to load post');
    }
  }
}
