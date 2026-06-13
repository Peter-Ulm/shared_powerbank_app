enum AppFlavor { mock, dev, prod }

class AppEnvironment {
  const AppEnvironment({required this.flavor, required this.apiBaseUrl});
  final AppFlavor flavor;
  final String apiBaseUrl;
  bool get useMockData => flavor == AppFlavor.mock;

  factory AppEnvironment.fromDartDefine() {
    const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'mock');
    const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:3000');
    final flavor = AppFlavor.values.firstWhere((f) => f.name == flavorName, orElse: () => AppFlavor.mock);
    return AppEnvironment(flavor: flavor, apiBaseUrl: baseUrl);
  }
}
