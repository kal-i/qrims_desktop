import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Core Services
import 'core/services/document_service/document_service.dart';
import 'core/services/document_service/font_service.dart';
import 'core/services/document_service/image_service.dart';
import 'core/services/entity_suggestions_service.dart';
import 'core/services/http_service.dart';
import 'core/services/item_suggestions_service.dart';
import 'core/services/officer_suggestions_service.dart';
import 'core/services/purchase_request_suggestions_service.dart';

// Authentication
import 'features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'features/auth/data/data_sources/remote/auth_remote_data_source_impl.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/user_login.dart';
import 'features/auth/domain/usecases/user_logout.dart';
import 'features/auth/domain/usecases/user_register.dart';
import 'features/auth/domain/usecases/user_reset_password.dart';
import 'features/auth/domain/usecases/user_send_otp.dart';
import 'features/auth/domain/usecases/user_update_info.dart';
import 'features/auth/domain/usecases/user_verify_otp.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Navigation
import 'features/navigation/data/data/data_sources/remote/notification_remote_data_source.dart';
import 'features/navigation/data/data/data_sources/remote/notification_remote_data_source_impl.dart';
import 'features/navigation/data/data/repository/notification_repository_impl.dart';
import 'features/navigation/domain/domain/repository/notification_repository.dart';
import 'features/navigation/domain/domain/usecases/get_notifications.dart';
import 'features/navigation/domain/domain/usecases/read_notification.dart';
import 'features/navigation/presentation/bloc/notifications_bloc.dart';
import 'features/navigation/presentation/components/side_navigation_drawer/bloc/side_navigation_drawer_bloc.dart';

// Dashboard
import 'features/dashboard/data/data_sources/remote/dashboard_remote_data_source.dart';
import 'features/dashboard/data/data_sources/remote/dashboard_remote_data_source_impl.dart';
import 'features/dashboard/data/data_sources/remote/user_activity_remote_data_source.dart';
import 'features/dashboard/data/data_sources/remote/user_activity_remote_data_source_impl.dart';
import 'features/dashboard/data/repository/dashboard_repository_impl.dart';
import 'features/dashboard/data/repository/user_activity_repository_impl.dart';
import 'features/dashboard/domain/repository/dashboard_repository.dart';
import 'features/dashboard/domain/repository/user_activity_repository.dart';
import 'features/dashboard/domain/usecases/get_inventory_summary.dart';
import 'features/dashboard/domain/usecases/get_low_stock_items.dart';
import 'features/dashboard/domain/usecases/get_most_requested_items.dart';
import 'features/dashboard/domain/usecases/get_user_activities.dart';
import 'features/dashboard/presentation/bloc/dashboard/inventory_summary/inventory_summary_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/low_stock/low_stock_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard/requests_summary/requests_summary_bloc.dart';
import 'features/dashboard/presentation/bloc/user_activity/user_activity_bloc.dart';

// Item Inventory
import 'features/item_inventory/data/data_sources/remote/item_inventory_remote_data_source_impl.dart';
import 'features/item_inventory/data/data_sources/remote/item_inventory_remote_date_source.dart';
import 'features/item_inventory/data/repository/item_inventory_repository_impl.dart';
import 'features/item_inventory/domain/repository/item_inventory_repository.dart';
import 'features/item_inventory/domain/usecases/register_equipment_item.dart';
import 'features/item_inventory/domain/usecases/register_supply_item.dart';
import 'features/item_inventory/domain/usecases/get_item_by_id.dart';
import 'features/item_inventory/domain/usecases/get_items.dart';
import 'features/item_inventory/domain/usecases/update_item.dart';
import 'features/item_inventory/presentation/bloc/item_inventory_bloc.dart';

// Item Issuance
import 'features/item_issuance/data/data_sources/remote/issuance_remote_data_source.dart';
import 'features/item_issuance/data/data_sources/remote/issuance_remote_data_source_impl.dart';
import 'features/item_issuance/data/repository/issuance_repository_impl.dart';
import 'features/item_issuance/domain/repository/issuance_repository.dart';
import 'features/item_issuance/domain/usecases/create_ics.dart';
import 'features/item_issuance/domain/usecases/create_par.dart';
import 'features/item_issuance/domain/usecases/get_issuance_by_id.dart';
import 'features/item_issuance/domain/usecases/get_paginated_issuances.dart';
import 'features/item_issuance/domain/usecases/match_item_with_pr.dart';
import 'features/item_issuance/domain/usecases/update_issuance_archive_status.dart';
import 'features/item_issuance/presentation/bloc/issuances_bloc.dart';

// Officers Management
import 'features/officer/data/data_sources/remote/officer_remote_data_source.dart';
import 'features/officer/data/data_sources/remote/officer_remote_data_source_impl.dart';
import 'features/officer/data/repository/officer_repository_impl.dart';
import 'features/officer/domain/repository/officer_repository.dart';
import 'features/officer/domain/usecases/get_paginated_officers.dart';
import 'features/officer/domain/usecases/register_officer.dart';
import 'features/officer/domain/usecases/update_officer_archive_status.dart';
import 'features/officer/presentation/bloc/officers_bloc.dart';

/// Purchase Requests
import 'features/purchase_request/data/data_sources/remote/purchase_request_remote_data_source.dart';
import 'features/purchase_request/data/data_sources/remote/purchase_request_remote_data_source_impl.dart';
import 'features/purchase_request/data/repository/purchase_request_repository_impl.dart';
import 'features/purchase_request/domain/repository/purchase_request_repository.dart';
import 'features/purchase_request/domain/usecases/get_paginated_purchase_requests.dart';
import 'features/purchase_request/domain/usecases/get_purchase_request_by_id.dart';
import 'features/purchase_request/domain/usecases/register_purchase_request.dart';
import 'features/purchase_request/domain/usecases/update_purchase_request_status.dart';
import 'features/purchase_request/presentation/bloc/purchase_requests_bloc.dart';

/// Users Management
import 'features/users_management/data/data_sources/remote/users_management_remote_data_source.dart';
import 'features/users_management/data/data_sources/remote/users_management_remote_data_source_impl.dart';
import 'features/users_management/data/repository/users_management_repository_impl.dart';
import 'features/users_management/domain/repository/users_management_repository.dart';
import 'features/users_management/domain/usecases/get_pending_users.dart';
import 'features/users_management/domain/usecases/get_users.dart';
import 'features/users_management/domain/usecases/update_admin_approval_status.dart';
import 'features/users_management/domain/usecases/update_user_auth_status.dart';
import 'features/users_management/domain/usecases/update_user_archive_status.dart';
import 'features/users_management/presentation/bloc/users_management_bloc.dart';

/// Archive Management
import 'features/archive/data/user/data_sources/remote/archive_users_remote_data_source.dart';
import 'features/archive/data/user/data_sources/remote/archive_users_remote_data_source_impl.dart';
import 'features/archive/data/user/repository/archive_user_repository_impl.dart';
import 'features/archive/domain/users/repository/archive_users_repository.dart';
import 'features/archive/domain/users/usecases/get_archived_users.dart';
import 'features/archive/domain/users/usecases/update_user_archive_status.dart';
import 'features/archive/presentation/bloc/archive_user_bloc/archive_users_bloc.dart';

part 'init_dependencies.main.dart';
