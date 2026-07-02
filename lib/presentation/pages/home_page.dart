import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot_manager/presentation/viewmodels/protocol_list_viewmodel.dart';
import 'package:iot_manager/presentation/viewmodels/certificate_list_viewmodel.dart';
import 'package:iot_manager/presentation/viewmodels/connection_list_viewmodel.dart';
import 'package:iot_manager/presentation/viewmodels/dashboard_viewmodel.dart';

final getIt = GetIt.instance;

/// Home page - Main navigation hub for the IoT Manager application
/// 
/// Provides navigation to:
/// - Dashboard: System overview and metrics
/// - Protocols: Protocol management
/// - Connections: Connection management
/// - Settings: User preferences and configuration
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late ProtocolListViewModel _protocolViewModel;
  late CertificateListViewModel _certificateViewModel;
  late ConnectionListViewModel _connectionViewModel;
  late DashboardViewModel _dashboardViewModel;

  @override
  void initState() {
    super.initState();
    _initializeViewModels();
  }

  void _initializeViewModels() {
    try {
      _protocolViewModel = getIt<ProtocolListViewModel>();
      _certificateViewModel = getIt<CertificateListViewModel>();
      _connectionViewModel = getIt<ConnectionListViewModel>();
      _dashboardViewModel = getIt<DashboardViewModel>();

      _protocolViewModel.initialize();
      _certificateViewModel.initialize();
      _connectionViewModel.initialize();
      _dashboardViewModel.initialize();
    } catch (e) {
      // Log error - show message after frame is rendered
      debugPrint('Error initializing ViewModels: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error initializing application')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Manager'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildPageContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.router),
            label: 'Protocols',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud_done),
            label: 'Connections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardPreview();
      case 1:
        return _buildProtocolsPreview();
      case 2:
        return _buildConnectionsPreview();
      case 3:
        return _buildSettingsPreview();
      default:
        return _buildDashboardPreview();
    }
  }

  Widget _buildDashboardPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard, size: 64, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('System overview and metrics'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to DashboardPage
            },
            child: const Text('View Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolsPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.router, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Protocols',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Manage IoT protocols'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to ProtocolListPage
            },
            child: const Text('View Protocols'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_done, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'Connections',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Monitor and manage connections'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to ConnectionListPage
            },
            child: const Text('View Connections'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Configure your preferences'),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Navigate to SettingsPage
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'IoT Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Connected Device Management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.router),
            title: const Text('Protocols'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_done),
            title: const Text('Connections'),
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.topic),
            title: const Text('Topics'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to TopicsPage
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text('Messages'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to MessagesPage
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Logs'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to LogsPage
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(context: context);
            },
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
