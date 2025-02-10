import 'package:dio/dio.dart' as diohttp;

const int iConnectTimeOutMs = 2000;
const int iReceiveTimeOutMs = 2400;

const int iTimeoutRetryDelayMs = iConnectTimeOutMs + iReceiveTimeOutMs;

final dioOptions = diohttp.BaseOptions(
  connectTimeout: const Duration(milliseconds: iConnectTimeOutMs),
  receiveTimeout: const Duration(milliseconds: iReceiveTimeOutMs),
);
typedef DioHttp = diohttp.Dio;
typedef DioResponse = diohttp.Response;
typedef DioException = diohttp.DioException;
typedef DioExceptionType = diohttp.DioExceptionType;

const int nTimeoutRequestRetry4RequestAutoReg = 0;
const int nTimeoutRequestRetry4InsertResults = 0;
const int nTimeoutRequestRetry4AutoRegTracking = 0;
const int nTimeoutRequestRetry4ListUserResults = 0;
const int nTimeoutRequestRetry4ListModelResults = 0;
const int nTimeoutRequestRetry4ProfileHandler = 0;
