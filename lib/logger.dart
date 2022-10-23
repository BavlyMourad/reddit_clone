import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Logger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint('''
  {
    ADDED
    "provider": "${provider.name ?? provider.runtimeType}",
    "value": "$value"
  }
''');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
//     debugPrint('''
//   {
//     UPDATED
//     "provider": "${provider.name ?? provider.runtimeType}",
//     "newValue": "$newValue"
//   }
// ''');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    debugPrint('''
  {
    DISPOSED
    "provider": "${provider.name ?? provider.runtimeType}"
  }
''');
  }
}
