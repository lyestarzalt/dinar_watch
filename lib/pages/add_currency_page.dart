import 'package:flutter/material.dart';
import '../models/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCurrencyPage extends StatefulWidget {
  final List<Currency> existingCurrencies;

  const AddCurrencyPage({super.key, required this.existingCurrencies});

  @override
  _AddCurrencyPageState createState() => _AddCurrencyPageState();
}

class _AddCurrencyPageState extends State<AddCurrencyPage> {
  List<Currency> selectedCurrencies = [];
  List<Currency> filteredCurrencies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCurrencies = widget.existingCurrencies; // Start with all currencies
    _loadSelectedCurrencies();
    searchController.addListener(_filterCurrencies);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCurrencies() {
    String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredCurrencies = widget.existingCurrencies
          .where((currency) => currency.name.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  void _loadSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedCurrencyNames =
        prefs.getStringList('selectedCurrencies') ?? [];
    setState(() {
      // Initialize with all existing currencies marked as selected if they are in saved preferences
      selectedCurrencies = widget.existingCurrencies
          .where((currency) => savedCurrencyNames.contains(currency.name))
          .toList();
    });
  }

  void _saveSelectedCurrencies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currencyNames = selectedCurrencies.map((c) => c.name).toList();
    await prefs.setStringList('selectedCurrencies', currencyNames);
  }

  void _addSelectedCurrencies() {
    _saveSelectedCurrencies();
    Navigator.pop(context, selectedCurrencies);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Extra Currencies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _addSelectedCurrencies,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCurrencies.length,
              itemBuilder: (context, index) {
                Currency currency = filteredCurrencies[index];
                bool isSelected = selectedCurrencies.contains(currency);
                return ListTile(
                  title: Text(currency.name),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle)
                      : const Icon(Icons.check_circle_outline),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedCurrencies.remove(currency);
                      } else {
                        selectedCurrencies.add(currency);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
