import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot_manager/domain/entities/dashboard.dart';
import 'package:iot_manager/presentation/viewmodels/dashboard_viewmodel.dart';

final getIt = GetIt.instance;

/// Dashboard Page - System overview with real-time metrics
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<DashboardViewModel>();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _viewModel.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => _viewModel.loadDashboards(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Health
                    _buildSystemHealth(),
                    const SizedBox(height: 24),
                    
                    // Quick Stats
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                    
                    // Dashboards List
                    _buildDashboardsList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDashboardDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<int>(
              valueListenable: _viewModel.systemHealthScore,
              builder: (context, healthScore, _) {
                return Column(
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: CircularProgressIndicator(
                              value: healthScore / 100,
                              strokeWidth: 8,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                healthScore > 75
                                    ? Colors.green
                                    : healthScore > 50
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              backgroundColor: Colors.grey[300],
                            ),
                          ),
                          Text(
                            '$healthScore%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      healthScore > 75
                          ? 'System is running smoothly'
                          : healthScore > 50
                              ? 'System performance is good'
                              : 'System needs attention',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Active Connections',
            _viewModel.activeConnectionCount,
            Colors.green,
            Icons.cloud_done,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Messages',
            _viewModel.totalMessagesCount,
            Colors.blue,
            Icons.mail,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    ValueNotifier<int> value,
    Color color,
    IconData icon,
  ) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, count, _) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActivityItem(
                'Connection established',
                'MQTT Connection',
                '2 minutes ago',
                Colors.green,
              ),
              _buildActivityItem(
                'Message received',
                'Topic: sensors/temperature',
                '5 minutes ago',
                Colors.blue,
              ),
              _buildActivityItem(
                'Protocol configured',
                'MQTT Protocol v3.1.1',
                '1 hour ago',
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    Color color,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(Icons.check_circle, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildDashboardsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Dashboards',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<List<Dashboard>>(
          valueListenable: _viewModel.dashboards,
          builder: (context, dashboards, _) {
            if (dashboards.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.dashboard, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('No dashboards yet'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _showCreateDashboardDialog(context),
                          child: const Text('Create Dashboard'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboards.length,
              itemBuilder: (context, index) {
                final dashboard = dashboards[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: Text(dashboard.name),
                    subtitle: Text(dashboard.description),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Text('View'),
                          onTap: () {
                            _viewModel.selectDashboard(dashboard);
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Edit'),
                          onTap: () {
                            // Edit dashboard
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            _viewModel.deleteDashboard(dashboard.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showCreateDashboardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Dashboard'),
        content: const Text('Dashboard creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create dashboard
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
