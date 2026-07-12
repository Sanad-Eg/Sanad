import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:sanad/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sanad/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:sanad/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:sanad/features/auth/domain/repositories/auth_repository.dart';
import 'package:sanad/features/auth/domain/usecases/login_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/register_client_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/register_helper_usecase.dart';
import 'package:sanad/features/auth/domain/usecases/upload_profile_image_usecase.dart';
import 'package:sanad/features/auth/presentation/cubit/auth_cubit.dart';

// Helper Discovery imports
import 'package:sanad/features/helper_discovery/data/datasources/helper_remote_data_source.dart';
import 'package:sanad/features/helper_discovery/data/datasources/helper_remote_data_source_impl.dart';
import 'package:sanad/features/helper_discovery/data/repositories/firebase_helper_repository_impl.dart';
import 'package:sanad/features/helper_discovery/domain/repositories/helper_repository.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helper_profile_usecase.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helpers_usecase.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helper_profile_stream_usecase.dart';
import 'package:sanad/features/helper_discovery/domain/usecases/get_helper_reviews_usecase.dart';
import 'package:sanad/features/helper_discovery/presentation/cubit/helper_discovery_cubit.dart';

// Booking Flow imports
import 'package:sanad/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:sanad/features/booking/data/datasources/booking_remote_data_source_impl.dart';
import 'package:sanad/features/booking/data/repositories/firebase_booking_repository_impl.dart';
import 'package:sanad/features/booking/domain/repositories/booking_repository.dart';
import 'package:sanad/features/booking/domain/usecases/accept_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/confirm_completion_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/counter_offer_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/get_booking_stream_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/pay_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/reject_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/send_booking_request_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/submit_review_usecase.dart';
import 'package:sanad/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:sanad/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/track_booking_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/get_client_bookings_usecase.dart';
import 'package:sanad/features/booking/domain/usecases/get_helper_bookings_usecase.dart';
import 'package:sanad/features/booking/presentation/cubit/my_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/client_bookings_cubit.dart';
import 'package:sanad/features/booking/presentation/cubit/helper_bookings_cubit.dart';

// Chat Feature imports
import 'package:sanad/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:sanad/features/chat/data/datasources/chat_remote_data_source_impl.dart';
import 'package:sanad/features/chat/data/repositories/firebase_chat_repository_impl.dart';
import 'package:sanad/features/chat/domain/repositories/chat_repository.dart';
import 'package:sanad/features/chat/domain/usecases/get_my_chats_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/get_chat_messages_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/get_chat_stream_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:sanad/features/chat/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:sanad/features/chat/presentation/cubit/chat_room_cubit.dart';

// Firebase Storage & Medical Vault Feature imports
import 'package:firebase_storage/firebase_storage.dart';

// Emergency Contacts Feature imports
import 'package:sanad/features/emergency/data/datasources/emergency_remote_data_source.dart';
import 'package:sanad/features/emergency/data/datasources/emergency_remote_data_source_impl.dart';
import 'package:sanad/features/emergency/data/repositories/firebase_emergency_repository_impl.dart';
import 'package:sanad/features/emergency/domain/repositories/emergency_repository.dart';
import 'package:sanad/features/emergency/domain/usecases/add_emergency_contact_usecase.dart';
import 'package:sanad/features/emergency/domain/usecases/remove_emergency_contact_usecase.dart';
import 'package:sanad/features/emergency/domain/usecases/get_emergency_contacts_usecase.dart';
import 'package:sanad/features/emergency/presentation/cubit/emergency_cubit.dart';

// Notifications Feature imports
import 'package:sanad/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:sanad/features/notifications/data/datasources/notification_remote_data_source_impl.dart';
import 'package:sanad/features/notifications/data/repositories/firebase_notification_repository_impl.dart';
import 'package:sanad/features/notifications/domain/repositories/notification_repository.dart';
import 'package:sanad/features/notifications/domain/usecases/get_notifications_stream_usecase.dart';
import 'package:sanad/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:sanad/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:sanad/features/notifications/presentation/cubit/notifications_cubit.dart';

// Admin Feature imports
import 'package:sanad/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:sanad/features/admin/data/datasources/admin_remote_data_source_impl.dart';
import 'package:sanad/features/admin/data/repositories/firebase_admin_repository_impl.dart';
import 'package:sanad/features/admin/domain/repositories/admin_repository.dart';
import 'package:sanad/features/admin/domain/usecases/get_pending_helpers_usecase.dart';
import 'package:sanad/features/admin/domain/usecases/update_helper_verification_status_usecase.dart';
import 'package:sanad/features/admin/domain/usecases/get_users_usecase.dart';
import 'package:sanad/features/admin/domain/usecases/get_all_bookings_usecase.dart';
import 'package:sanad/features/admin/domain/usecases/approve_helper_usecase.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_users_cubit.dart';
import 'package:sanad/features/admin/presentation/cubit/admin_bookings_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================================
  // Auth Feature
  // ==========================================

  // Cubit
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      login: sl(),
      registerClient: sl(),
      registerHelper: sl(),
      logout: sl(),
      uploadProfileImage: sl(),
      firebaseAuth: sl(),
      remoteDataSource: sl(),
      authRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterClientUseCase(sl()));
  sl.registerLazySingleton(() => RegisterHelperUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UploadProfileImageUseCase(sl()));

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firestore: sl()),
  );

  // External: Firebase singletons
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => FirebaseAuthRepositoryImpl(
      firebaseAuth: sl(),
      remoteDataSource: sl(),
    ),
  );

  // ==========================================
  // Helper Discovery Feature
  // ==========================================

  // Cubit
  sl.registerFactory<HelperDiscoveryCubit>(
    () => HelperDiscoveryCubit(
      getHelpers: sl(),
      getHelperProfile: sl(),
      getHelperProfileStream: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetHelpersUseCase(sl()));
  sl.registerLazySingleton(() => GetHelperProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetHelperProfileStreamUseCase(sl()));
  sl.registerLazySingleton(() => GetHelperReviewsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HelperRepository>(
    () => FirebaseHelperRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<HelperRemoteDataSource>(
    () => HelperRemoteDataSourceImpl(firestore: sl()),
  );

  // ==========================================
  // Booking Feature
  // ==========================================

  // Cubit
  sl.registerFactory<BookingCubit>(
    () => BookingCubit(
      sendBookingRequest: sl(),
      acceptBooking: sl(),
      rejectBooking: sl(),
      counterOffer: sl(),
      payBooking: sl(),
      confirmCompletion: sl(),
      trackBooking: sl(),
      submitReview: sl(),
    ),
  );

  sl.registerFactory<MyBookingsCubit>(
    () => MyBookingsCubit(
      getMyBookings: sl(),
    ),
  );

  sl.registerFactory<ClientBookingsCubit>(
    () => ClientBookingsCubit(
      getClientBookings: sl(),
    ),
  );

  sl.registerFactory<HelperBookingsCubit>(
    () => HelperBookingsCubit(
      getHelperBookings: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SendBookingRequestUseCase(sl()));
  sl.registerLazySingleton(() => AcceptBookingUseCase(sl()));
  sl.registerLazySingleton(() => RejectBookingUseCase(sl()));
  sl.registerLazySingleton(() => CounterOfferUseCase(sl()));
  sl.registerLazySingleton(() => PayBookingUseCase(sl()));
  sl.registerLazySingleton(() => ConfirmCompletionUseCase(sl()));
  sl.registerLazySingleton(() => GetBookingStreamUseCase(sl()));
  sl.registerLazySingleton(() => TrackBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetMyBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetClientBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetHelperBookingsUseCase(sl()));
  sl.registerLazySingleton(() => SubmitReviewUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BookingRepository>(
    () => FirebaseBookingRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(firestore: sl()),
  );

  // ==========================================
  // Chat Feature
  // ==========================================

  // Cubits
  sl.registerFactory<ChatListCubit>(
    () => ChatListCubit(getMyChats: sl()),
  );
  sl.registerFactory<ChatRoomCubit>(
    () => ChatRoomCubit(
      getChatMessages: sl(),
      getChatStream: sl(),
      sendMessage: sl(),
      markMessagesAsRead: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetMyChatsUseCase(sl()));
  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetChatStreamUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkMessagesAsReadUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => FirebaseChatRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  // ==========================================
  // Emergency Contacts Feature
  // ==========================================

  // Cubits
  sl.registerFactory<EmergencyCubit>(
    () => EmergencyCubit(
      getEmergencyContacts: sl(),
      addEmergencyContact: sl(),
      removeEmergencyContact: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => AddEmergencyContactUseCase(sl()));
  sl.registerLazySingleton(() => RemoveEmergencyContactUseCase(sl()));
  sl.registerLazySingleton(() => GetEmergencyContactsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<EmergencyRepository>(
    () => FirebaseEmergencyRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<EmergencyRemoteDataSource>(
    () => EmergencyRemoteDataSourceImpl(firestore: sl()),
  );

  // ==========================================
  // Notifications Feature
  // ==========================================

  // Cubits
  sl.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(
      getNotificationsStream: sl(),
      markNotificationAsRead: sl(),
      markAllNotificationsAsRead: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNotificationsStreamUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsReadUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => FirebaseNotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl()),
  );

  // ==========================================
  // Admin Feature
  // ==========================================

  // Cubits
  sl.registerFactory<AdminCubit>(
    () => AdminCubit(
      getPendingHelpers: sl(),
      updateHelperVerificationStatus: sl(),
    ),
  );

  sl.registerFactory<AdminUsersCubit>(
    () => AdminUsersCubit(
      getUsers: sl(),
      approveHelper: sl(),
    ),
  );

  sl.registerFactory<AdminBookingsCubit>(
    () => AdminBookingsCubit(getAllBookings: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPendingHelpersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHelperVerificationStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetAllBookingsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveHelperUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => FirebaseAdminRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl()),
  );
}
