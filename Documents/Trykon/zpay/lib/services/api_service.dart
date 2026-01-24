import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple singleton ApiService that attaches an Authorization header from secure storage
class ApiService {
  final Dio dio;
  final FlutterSecureStorage _storage;

  ApiService._internal(this.dio, this._storage) {
    dio.options = BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {}
        return handler.next(options);
      },
      onError: (err, handler) async {
        // Global error handling placeholder
        return handler.next(err);
      },
    ));
  }

  static final ApiService _instance =
      ApiService._internal(Dio(), const FlutterSecureStorage());

  factory ApiService() => _instance;

  Future<Response<T>> get<T>(String path,
          {Map<String, dynamic>? queryParameters}) =>
      dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path,
          {data, Map<String, dynamic>? queryParameters}) =>
      dio.post<T>(path, data: data, queryParameters: queryParameters);

  /// Fetch exchange rates for given symbols using exchangerate.host (free)
  /// Returns map like { 'USD': 1.0, 'EUR': 0.92, ... }
  Future<Map<String, double>> fetchExchangeRates(
      {String base = 'USD', List<String>? symbols}) async {
    try {
      final symList = (symbols ?? ['USD', 'EUR', 'GBP', 'NGN']).join(',');
      final resp = await dio.get('https://api.exchangerate.host/latest',
          queryParameters: {'base': base, 'symbols': symList});
      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        final rates = (data['rates'] as Map).map<String, double>(
            (k, v) => MapEntry(k as String, (v as num).toDouble()));
        return rates;
      }
    } catch (_) {}
    // Fallback mock data
    return {'USD': 1.0, 'EUR': 0.92, 'GBP': 0.82, 'NGN': 0.0016};
  }

  /// Fetch BTC price in USD using CoinGecko
  Future<double> fetchBitcoinUsdPrice() async {
    try {
      final resp = await dio.get(
          'https://api.coingecko.com/api/v3/simple/price',
          queryParameters: {'ids': 'bitcoin', 'vs_currencies': 'usd'});
      if (resp.statusCode == 200) {
        final data = resp.data as Map<String, dynamic>;
        final btc = data['bitcoin'] as Map<String, dynamic>?;
        if (btc != null && btc['usd'] != null)
          return (btc['usd'] as num).toDouble();
      }
    } catch (_) {}
    return 43000.0; // fallback
  }

  /// Fetch recent transactions for current user (mock if API not available)
  Future<List<Map<String, dynamic>>> fetchRecentTransactions(
      {int limit = 10}) async {
    try {
      final resp = await dio
          .get('/transactions', queryParameters: {'limit': limit.toString()});
      if (resp.statusCode == 200 && resp.data is List) {
        return List<Map<String, dynamic>>.from(resp.data as List);
      }
    } catch (_) {}
    // fallback: generate mock transactions
    return List.generate(limit, (i) {
      final isCredit = i % 3 == 0;
      return {
        'id': 'tx_$i',
        'date': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        'currency': i % 2 == 0 ? 'USD' : 'NGN',
        'amount': (i + 1) * (isCredit ? 42.5 : -24.8),
        'description': isCredit ? 'Top-up' : 'Coffee purchase',
        'type': isCredit ? 'credit' : 'debit',
      };
    });
  }
}
