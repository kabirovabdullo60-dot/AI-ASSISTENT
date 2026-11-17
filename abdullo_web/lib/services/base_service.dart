import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import 'mock/mock_database.dart';

/// Every service either answers from the demo database or calls Mehroj's API.
abstract class BaseService {
  BaseService({ApiClient? client, bool? useMock})
    : client = client ?? ApiClient(),
      useMock = useMock ?? ApiConstants.useMock;

  /// Fake network delay in demo mode (tests set it to zero).
  static Duration mockDelay = const Duration(milliseconds: 350);

  final ApiClient client;
  final bool useMock;

  @protected
  Future<T> mockOr<T>({required T Function(MockDatabase db) mock, required Future<T> Function() api}) async {
    if (!useMock) return api();
    await Future<void>.delayed(mockDelay);
    return mock(MockDatabase.instance);
  }
}
