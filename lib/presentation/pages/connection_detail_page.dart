import 'package:flutter/material.dart';
import 'package:iot_manager/domain/entities/connection.dart';

/// Connection Detail Page - View and edit connection details
class ConnectionDetailPage extends StatefulWidget {
  final Connection connection;

  const ConnectionDetailPage({
    Key? key,
    required this.connection,
  }) : super(key: key);

  @override
  State<ConnectionDetailPage> createState() => _ConnectionDetailPageState();
}

class _ConnectionDetailPageState extends State<ConnectionDetailPage> {
  late TextEditingController _nameController;
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.connection.name);
    _hostController = TextEditingController(text: widget.connection.host);
    _portController = TextEditingController(text: widget.connection.port.toString());
    _usernameController = TextEditingController(text: widget.connection.username ?? '');
    _passwordController = TextEditingController(text: widget.connection.password ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Details'),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
            )
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _saveChanges(),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _isEditMode = false),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: widget.connection.status == ConnectionStatus.active
                    ? Colors.green[50]
                    : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_done,
                        color: widget.connection.status == ConnectionStatus.active
                            ? Colors.green
                            : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.connection.status == ConnectionStatus.active
                                ? 'Connected'
                                : 'Disconnected',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Protocol: ${widget.connection.protocol}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Connection Settings
              const Text(
                'Connection Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Name', _nameController, enabled: _isEditMode),
              const SizedBox(height: 12),
              _buildTextField('Host', _hostController, enabled: _isEditMode),
              const SizedBox(height: 12),
              _buildTextField(
                'Port',
                _portController,
                enabled: _isEditMode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField('Username', _usernameController, enabled: _isEditMode),
              const SizedBox(height: 12),
              _buildTextField(
                'Password',
                _passwordController,
                enabled: _isEditMode,
                obscureText: true,
              ),
              const SizedBox(height: 24),
              // Actions
              if (!_isEditMode)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Reconnect
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reconnect'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Delete with confirmation
                          _showDeleteConfirmation(context);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // Metadata
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Created: ${widget.connection.createdAt}'),
              const SizedBox(height: 4),
              Text('Last Updated: ${widget.connection.updatedAt}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: !enabled,
        fillColor: !enabled ? Colors.grey[100] : null,
      ),
    );
  }

  void _saveChanges() {
    // Save connection changes
    setState(() => _isEditMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection updated')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Connection?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // Delete connection
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
