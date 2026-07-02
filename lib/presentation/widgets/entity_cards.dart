import 'package:flutter/material.dart';
import 'package:iot_manager/domain/entities/certificate.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/entities/protocol.dart';

/// Reusable entity card for displaying entity information
class EntityCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final List<String> details;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EntityCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor = Colors.blue,
    this.details = const [],
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: details
                            .take(2)
                            .map(
                              (detail) => Chip(
                                label: Text(
                                  detail,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null || onDelete != null)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: onEdit,
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: onDelete,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Protocol card widget
class ProtocolCard extends StatelessWidget {
  final Protocol protocol;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProtocolCard({
    Key? key,
    required this.protocol,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EntityCard(
      title: protocol.name,
      subtitle: protocol.type.toString(),
      icon: Icons.router,
      iconColor: Colors.green,
      details: [protocol.description],
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

/// Certificate card widget
class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CertificateCard({
    Key? key,
    required this.certificate,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isExpiring = certificate.expiresAt.difference(DateTime.now()).inDays < 30;

    return EntityCard(
      title: certificate.name,
      subtitle: 'Expires: ${certificate.expiresAt.toString().split(' ')[0]}',
      icon: Icons.security,
      iconColor: isExpiring ? Colors.orange : Colors.blue,
      details: [
        'Type: ${certificate.type}',
        isExpiring ? 'Expiring soon!' : 'Valid',
      ],
      onTap: onTap,
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

/// Connection card widget
class ConnectionCard extends StatelessWidget {
  final Connection connection;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ConnectionCard({
    Key? key,
    required this.connection,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_done,
                    color: connection.status == ConnectionStatus.active
                        ? Colors.green
                        : Colors.red,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connection.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${connection.host}:${connection.port}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      connection.status == ConnectionStatus.active
                          ? 'Active'
                          : 'Inactive',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor:
                        connection.status == ConnectionStatus.active
                            ? Colors.green
                            : Colors.grey,
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            child: const Text('Edit'),
                            onTap: onEdit,
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            child: const Text('Delete'),
                            onTap: onDelete,
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text(connection.protocol),
                    backgroundColor: Colors.blue[100],
                  ),
                  const SizedBox(width: 8),
                  if (connection.username != null)
                    Chip(
                      label: Text('Auth: ${connection.username}'),
                      backgroundColor: Colors.orange[100],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status indicator card
class StatusIndicatorCard extends StatelessWidget {
  final String title;
  final int value;
  final String unit;
  final Color color;
  final IconData icon;

  const StatusIndicatorCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
