import 'package:flutter/material.dart';
import 'package:dinar_watch/models/currency.dart';
import 'package:dinar_watch/providers/currency_selection_provider.dart';
import 'package:dinar_watch/widgets/currency_list_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_watch/pages/currencies_list/add_currency_page.dart';
class CurrencyListScreen extends StatelessWidget {
  const CurrencyListScreen({Key? key}) : super(key: key);


  
Future<void> _navigateToAddCurrencyPage(
      BuildContext context, CurrencySelectionProvider provider) async {
    final List<Currency>? newCurrencies = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCurrencyPage(existingCurrencies: provider.selectedCurrencies),
      ),
    );

    if (newCurrencies != null && newCurrencies.isNotEmpty) {
      provider.updateSelectedCurrencies(newCurrencies);
    }
  }

@override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<CurrencySelectionProvider>(
      create: (_) => CurrencySelectionProvider(),
      child: Consumer<CurrencySelectionProvider>(
        builder: (context, selectionProvider, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.currency_list),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
              child: RefreshIndicator(
                onRefresh: () async {
                  // TODO Implement the refresh logic
                },
                child: ReorderableListView.builder(
                  itemCount: selectionProvider.selectedCurrencies.length,
                  itemBuilder: (context, index) {
                    final Currency currency =
                        selectionProvider.selectedCurrencies[index];
                    return CurrencyListItem(
                      key: ValueKey(currency.currencyCode),
                      currency: currency,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    selectionProvider.reorderCurrencies(oldIndex, newIndex);
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  _navigateToAddCurrencyPage(context, selectionProvider),
              tooltip: AppLocalizations.of(context)!.add_currencies,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

}
