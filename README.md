# Deo Emerges

An advanced Flutter networking package built on top of Dio, offering concurrent request handling, comprehensive error management, and extensive features for modern Flutter applications.

[![pub package](https://img.shields.io/pub/v/deo_emerges.svg)](https://pub.dev/packages/deo_emerges)
[![Flutter Platform](https://img.shields.io/badge/Platform-Flutter-02569B.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **Concurrent Request Handling**: Make multiple HTTP requests simultaneously with efficient connection management
- **Comprehensive Error Handling**: Detailed error messages and codes with retry mechanisms using exponential backoff
- **Request Cancellation**: Gracefully cancel ongoing HTTP requests
- **Interceptors**: Modify requests and responses with built-in interceptors for logging, caching, authentication, and more
- **Customizable Timeout Settings**: Configure connection, read, and write timeout durations
- **Secure Communication**: Built-in support for SSL pinning and secure data transmission
- **State Management Integration**: Seamless compatibility with Provider, Riverpod, and Bloc
- **Performance Optimization**: Minimal overhead for fast and efficient networking operations

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  deo_emerges: ^0.1.3
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:deo_emerges/deo_emerges.dart';

void main() async {
  // Create a client
  final client = DeoClient(
    config: DeoConfig(
      baseUrl: 'https://api.example.com',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      sendTimeout: Duration(seconds: 10),
    ),
  );
  
  // Make a GET request
  try {
    final response = await client.get<Map<String, dynamic>>('/users');
    print(response.data);
  } catch (e) {
    if (e is DeoError) {
      print('Error: ${e.message}');
    }
  }
}
```

### Concurrent Requests

```dart
final responses = await client.concurrent([
  () => client.get('/users'),
  () => client.get('/posts'),
  () => client.get('/comments'),
]);
```

### Request Cancellation

```dart
// Create a request with a cancel token
final response = await client.get('/users', cancelToken: 'userRequest');

// Cancel the request
client.cancelRequest('userRequest');
```

### Using with Provider

```dart
final adapter = DeoProviderAdapter(DeoClient());

// In your widget
final result = await adapter.execute(() => adapter.client.get('/users'));

// Check loading state
if (adapter.isLoading) {
  return CircularProgressIndicator();
}

// Check for errors
if (adapter.error != null) {
  return Text('Error: ${adapter.error!.message}');
}
```

### Using with Riverpod

```dart
// Define a provider
final apiProvider = StateNotifierProvider<DeoRiverpodAdapter, DeoState>((ref) {
  return DeoRiverpodAdapter(DeoClient());
});

// In your widget
final apiState = ref.watch(apiProvider);
final apiNotifier = ref.read(apiProvider.notifier);

// Execute a request
final result = await apiNotifier.execute(() => apiNotifier.client.get('/users'));

// Check state
if (apiState.isLoading) {
  return CircularProgressIndicator();
}

if (apiState.error != null) {
  return Text('Error: ${apiState.error!.message}');
}
```

### Using with Bloc

```dart
class UserBloc extends Bloc<UserEvent, UserState> {
  final DeoBlocAdapter _api = DeoBlocAdapter(DeoClient());
  
  UserBloc() : super(UserInitial()) {
    on<FetchUsers>((event, emit) async {
      await _api.execute(() => _api.client.get('/users'));
      
      // The state is automatically updated by the adapter
      if (_api.state.isLoading) {
        emit(UserLoading());
      } else if (_api.state.error != null) {
        emit(UserError(_api.state.error!));
      } else {
        emit(UserLoaded(users));
      }
    });
  }
}
```

## Advanced Configuration

### Custom Interceptors

```dart
final client = DeoClient();

// Add a custom interceptor
client.addInterceptor(MyCustomInterceptor());
```

### SSL Pinning

```dart
final client = DeoClient(
  config: DeoConfig(
    validateCertificate: true,
    certificates: ['certificate1', 'certificate2'],
  ),
);
```

## Author

Developed by Tisankan

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.