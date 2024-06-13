import 'package:flutter/material.dart';
import 'package:dinar_echange/data/models/currency.dart';
import 'package:dinar_echange/providers/list_currency_provider.dart';
import 'package:dinar_echange/widgets/list/list_tile.dart';
import 'package:dinar_echange/l10n/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dinar_echange/views/currencies_list/add_currency_view.dart';
import 'package:dinar_echange/views/currencies_list/convert_currency_view.dart';
import 'package:dinar_echange/providers/converter_provider.dart';
import 'package:dinar_echange/providers/app_provider.dart';
import 'package:dinar_echange/providers/admob_provider.dart';
import 'package:dinar_echange/utils/logging.dart';

class CurrencyListScreen extends StatefulWidget {
  final String marketType;

  const CurrencyListScreen({Key? key, required this.marketType})
      : super(key: key);

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Consumer<ListCurrencyProvider>(
            builder: (_, provider, __) => ReorderableListView.builder(
              shrinkWrap: true,
              itemCount: provider.selectedCurrencies.length,
              itemBuilder: (context, index) =>
                  _buildCurrencyItem(context, provider, index),
              onReorder: provider.reorderCurrencies,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCurrencyPage(context),
        tooltip: AppLocalizations.of(context)!.add_currencies_tooltip,
        child: const Icon(Icons.add),
        heroTag: 'AddCurrencyFAB${widget.marketType}',
      ),
    );
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<ListCurrencyProvider>(context, listen: false);
    final appprovider = Provider.of<AppProvider>(context, listen: false);

    await provider.refreshData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.latest_updates_on} ${appprovider.getDatetime(provider.getFormattedDate())}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCurrencyItem(
      BuildContext context, ListCurrencyProvider provider, int index) {
    final currency = provider.selectedCurrencies[index];
    return Dismissible(
      key: ValueKey(currency.currencyCode),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => provider.addOrRemoveCurrency(currency, false),
      child: InkWell(
        onTap: () => _navigateToConverter(context, currency),
        child: CurrencyListItem(currency: currency),
      ),
    );
  }

  void _showAddCurrencyPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<ListCurrencyProvider>(context, listen: false),
          child: const AddCurrencyPage(),
        ),
      ),
    );
  }

  void _navigateToConverter(BuildContext context, Currency currency) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ConvertProvider(currency),
          child: const CurrencyConverterPage(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

void showAddCurrencyPage(
    BuildContext context, ListCurrencyProvider selectionProvider) {
  AppLogger.trackScreenView('AddCurrencies_Screen', 'MainList');
  final adProvider = Provider.of<AdProvider>(context, listen: false);

  adProvider.ensureAdIsReadyToShow(
    onReadyToShow: () => _navigateToAddCurrencyPage(context, selectionProvider),
    onFailToShow: () => _navigateToAddCurrencyPage(context, selectionProvider),
  );
}

void _navigateToAddCurrencyPage(
    BuildContext context, ListCurrencyProvider selectionProvider) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChangeNotifierProvider.value(
        value: selectionProvider,
        child: const AddCurrencyPage(),
      ),
    ),
  );
}
