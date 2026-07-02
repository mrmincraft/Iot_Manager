import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/presentation/viewmodels/connection_list_viewmodel.dart';

final getIt = GetIt.instance;

/// Connection List Page - Display and manage connections
class ConnectionListPage extends StatefulWidget {
  const ConnectionListPage({Key? key}) : super(key: key);

  @override
  State<ConnectionListPage> createState() => _ConnectionListPageState();
}

class _ConnectionListPageState extends State<ConnectionListPage> {
  late ConnectionListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ConnectionListViewModel>();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ValueListenableBuilder<int>(
              valueListenable: _viewModel.activeCount,
              builder: (context, activeCount, _) {
                return Center(
                  child: Text(
                    'Active: $activeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _viewModel.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<Connection>>(
            valueListenable: _viewModel.connections,
            builder: (context, connections, _) {
              if (connections.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_done, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No connections configured'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showConnectionDialog(context),
                        child: const Text('Add Connection'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _viewModel.loadConnections(),
                child: ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final connection = connections[index];
                    return ConnectionListItem(
                      connection: connection,
                      onTap: () {
                        _viewModel.selectConnection(connection);
                        _showConnectionDetailPage(context, connection);
                      },
                      onDelete: () => _deleteConnection(connection.id),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showConnectionDialog(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Connection'),
        content: const Text('Connection creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Connection would be created here
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showConnectionDetailPage(BuildContext context, Connection connection) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConnectionDetailPage(connection: connection),
      ),
    );
  }

  void _deleteConnection(String connectionId) {
    _viewModel.deleteConnection(connectionId);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ConnectionListItem extends StatelessWidget {
  final Connection connection;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConnectionListItem({
    Key? key,
    required this.connection,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          Icons.cloud_done,
          color: connection.status == ConnectionStatus.active ? Colors.green : Colors.red,
        ),
        title: Text(connection.name),
        subtitle: Text('${connection.protocol} - ${connection.host}:${connection.port}'),
        trailing: Chip(
          label: Text(
            connection.status == ConnectionStatus.active ? 'Active' : 'Inactive',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: connection.status == ConnectionStatus.active ? Colors.green : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
