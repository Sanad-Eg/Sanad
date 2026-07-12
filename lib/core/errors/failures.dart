sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('لا يوجد اتصال بالإنترنت');
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class BookingFailure extends Failure {
  const BookingFailure(super.message);
}

class ChatFailure extends Failure {
  const ChatFailure(super.message);
}

class VaultFailure extends Failure {
  const VaultFailure(super.message);
}

class EmergencyFailure extends Failure {
  const EmergencyFailure(super.message);
}

class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure() : super('حدث خطأ في الخادم، حاول مرة أخرى');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
