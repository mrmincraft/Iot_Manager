import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/presentation/viewmodels/protocol_list_viewmodel.dart';

final getIt = GetIt.instance;

/// Protocol List Page - Display and manage protocols
class ProtocolListPage extends StatefulWidget {
  const ProtocolListPage({Key? key}) : super(key: key);

  @override
  State<ProtocolListPage> createState() => _ProtocolListPageState();
}

class _ProtocolListPageState extends State<ProtocolListPage> {
  late ProtocolListViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ProtocolListViewModel>();
    _viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Protocols'),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _viewModel.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ValueListenableBuilder<List<Protocol>>(
            valueListenable: _viewModel.protocols,
            builder: (context, protocols, _) {
              if (protocols.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.router, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('No protocols configured'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showProtocolDialog(context),
                        child: const Text('Add Protocol'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _viewModel.loadProtocols(),
                child: ListView.builder(
                  itemCount: protocols.length,
                  itemBuilder: (context, index) {
                    final protocol = protocols[index];
                    return ProtocolListItem(
                      protocol: protocol,
                      onTap: () {
                        _viewModel.selectProtocol(protocol);
                        _showProtocolDetailDialog(context, protocol);
                      },
                      onDelete: () => _deleteProtocol(protocol.id),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProtocolDialog(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProtocolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Protocol'),
        content: const Text('Protocol creation form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Protocol would be created here
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showProtocolDetailDialog(BuildContext context, Protocol protocol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(protocol.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${protocol.type}'),
              const SizedBox(height: 8),
              Text('Description: ${protocol.description}'),
              const SizedBox(height: 8),
              Text('Created: ${protocol.createdAt}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Edit protocol
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _deleteProtocol(String protocolId) {
    _viewModel.deleteProtocol(protocolId);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ProtocolListItem extends StatelessWidget {
  final Protocol protocol;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProtocolListItem({
    Key? key,
    required this.protocol,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: const Icon(Icons.router, color: Colors.green),
        title: Text(protocol.name),
        subtitle: Text(protocol.type.toString()),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: onTap,
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
