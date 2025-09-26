import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../main.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/collection/presentation/providers/collection_provider.dart';
import '../../features/search/presentation/providers/search_provider.dart';
import '../../features/trading/presentation/providers/trading_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CollectionProvider()),
    ChangeNotifierProvider(create: (_) => SearchProvider()),
    ChangeNotifierProvider(create: (_) => TradingProvider()),
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
  ];
}
