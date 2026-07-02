import '../../core/events/app_event.dart';
import '../entities/dashboard.dart';

/// Event fired when a new dashboard is created
class DashboardCreatedEvent extends AppEvent {
  final Dashboard dashboard;

  DashboardCreatedEvent(this.dashboard);
}

/// Event fired when a dashboard is updated
class DashboardUpdatedEvent extends AppEvent {
  final Dashboard dashboard;
  final Dashboard? previousDashboard;

  DashboardUpdatedEvent({
    required this.dashboard,
    this.previousDashboard,
  });
}

/// Event fired when a dashboard is deleted
class DashboardDeletedEvent extends AppEvent {
  final String dashboardId;
  final Dashboard? deletedDashboard;

  DashboardDeletedEvent({
    required this.dashboardId,
    this.deletedDashboard,
  });
}

/// Event fired when all dashboards are loaded
class DashboardsLoadedEvent extends AppEvent {
  final List<Dashboard> dashboards;

  DashboardsLoadedEvent(this.dashboards);
}

/// Event fired when a dashboard is retrieved by ID
class DashboardRetrievedEvent extends AppEvent {
  final Dashboard dashboard;

  DashboardRetrievedEvent(this.dashboard);
}

/// Event fired when a dashboard is shared with another user
class DashboardSharedEvent extends AppEvent {
  final String dashboardId;
  final String sharedWithUserId;

  DashboardSharedEvent({
    required this.dashboardId,
    required this.sharedWithUserId,
  });
}
