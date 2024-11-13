import '../../src/services/apiInterface.dart';
import '../../src/services/dioApiService.dart';
import '../../src/services/httpApiService.dart';


const ApiImplementation currentImplementation = ApiImplementation.http;

enum ApiImplementation {
  http,
  dio,
}

ApiInterface createApiService() {
  switch (currentImplementation) {
    case ApiImplementation.http:
      return HttpApiService();
    case ApiImplementation.dio:
      return DioApiService();
    default:
      return DioApiService(); // Implementation par défaut
  }
}