import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final operationIdFactoryProvider = Provider<OperationIdFactory>((ref) {
  return const OperationIdFactory(Uuid());
});

class OperationIdFactory {
  const OperationIdFactory(this._uuid);

  final Uuid _uuid;

  String create() => _uuid.v4();
}
