class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelect = '/role-select';
  static const String login = '/login';
  static const String registerClient = '/register-client';
  static const String registerHelper = '/register-helper'; // we can pass step as extra or query parameter
  static const String verificationPending = '/verification-pending';
  static const String forgotPassword = '/forgot-password';

  // Client shell & sub-routes
  static const String clientHome = '/client-home';
  static const String clientBookings = '/client-bookings';
  static const String clientProfile = '/client-profile';
  static const String chatList = '/chat-list';

  // Helper shell & sub-routes
  static const String helperHome = '/helper-home';
  static const String helperBookings = '/helper-bookings';
  static const String helperSchedule = '/helper-schedule';
  static const String helperEarnings = '/helper-earnings';
  static const String helperProfile = '/helper-profile';
  static const String helperChatList = '/helper-chat-list';

  // Admin
  static const String adminPanel = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminBookings = '/admin/bookings';

  // Helper search & profile
  static const String search = '/search';
  static const String helperDetail = '/helper-detail'; // pass helperId as path parameter /helper/:id

  // Booking steps
  static const String bookDateTime = '/book-datetime'; // pass helperId as path param /book/:helperId/datetime
  static const String bookLocation = '/book-location';
  static const String bookTask = '/book-task';
  static const String bookSummary = '/book-summary';

  // Booking status / actions
  static const String bookingWaiting = '/booking-waiting'; // /booking/:id/waiting
  static const String bookingNegotiate = '/booking-negotiate';
  static const String bookingPayment = '/booking-payment';
  static const String bookingSuccess = '/booking-success';
  static const String bookingTracking = '/booking-track';
  static const String bookingActive = '/booking-active';
  static const String bookingConfirm = '/booking-confirm';
  static const String bookingRate = '/booking-rate';

  // Chat, notifications, emergency
  static const String chat = '/chat'; // /chat/:bookingId
  static const String notifications = '/notifications';
  static const String emergencyContacts = '/emergency-contacts';
  static const String helperIncomingRequest = '/incoming-request'; // /request/:id
  static const String changePassword = '/change-password';
}
