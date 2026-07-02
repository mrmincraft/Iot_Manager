import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/data/datasources/local/protocol_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/connection_local_datasource.dart';
import 'package:iot_manager/data/datasources/local/certificate_local_datasource.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/data/models/certificate_model.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/entities/certificate.dart';

void main() {
  group('LocalDataSource Implementation Tests', () {
    group('ProtocolLocalDataSourceImpl', () {
      late ProtocolLocalDataSource protocolLocalDataSource;

      setUp(() {
        // Initialize with mock database
        protocolLocalDataSource = ProtocolLocalDataSourceImpl();
      });

      test('getAllProtocols returns all stored protocols', () async {
        // Insert test data
        final protocol = ProtocolModel(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await protocolLocalDataSource.createProtocol(protocol);
        final result = await protocolLocalDataSource.getAllProtocols();

        expect(result, isNotEmpty);
        expect(result.first.name, 'MQTT');
      });

      test('getProtocolById returns specific protocol', () async {
        const protocolId = 'proto-001';
        final protocol = ProtocolModel(
          id: protocolId,
          name: 'HTTP',
          type: ProtocolType.http,
          port: 80,
        );

        await protocolLocalDataSource.createProtocol(protocol);
        final retrieved = await protocolLocalDataSource.getProtocolById(protocolId);

        expect(retrieved.id, protocolId);
        expect(retrieved.name, 'HTTP');
      });

      test('createProtocol stores protocol in local database', () async {
        final protocol = ProtocolModel(
          id: 'proto-new',
          name: 'CoAP',
          type: ProtocolType.coap,
          port: 5683,
        );

        final result = await protocolLocalDataSource.createProtocol(protocol);

        expect(result, isNotNull);
        expect(result, greaterThan(0));
      });

      test('updateProtocol modifies existing protocol', () async {
        const protocolId = 'proto-001';
        final protocol = ProtocolModel(
          id: protocolId,
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await protocolLocalDataSource.createProtocol(protocol);

        final updated = protocol.copyWith(port: 8883);
        await protocolLocalDataSource.updateProtocol(updated);

        final retrieved = await protocolLocalDataSource.getProtocolById(protocolId);
        expect(retrieved.port, 8883);
      });

      test('deleteProtocol removes protocol from database', () async {
        const protocolId = 'proto-001';
        final protocol = ProtocolModel(
          id: protocolId,
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        await protocolLocalDataSource.createProtocol(protocol);
        final deleted = await protocolLocalDataSource.deleteProtocol(protocolId);

        expect(deleted, greaterThanOrEqualTo(0));

        // Verify deletion
        final all = await protocolLocalDataSource.getAllProtocols();
        expect(all.where((p) => p.id == protocolId), isEmpty);
      });

      test('getProtocolsByType filters protocols by type', () async {
        final mqtt = ProtocolModel(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final http = ProtocolModel(
          id: 'proto-002',
          name: 'HTTP',
          type: ProtocolType.http,
          port: 80,
        );

        await protocolLocalDataSource.createProtocol(mqtt);
        await protocolLocalDataSource.createProtocol(http);

        final mqttProtocols = await protocolLocalDataSource.getProtocolsByType(ProtocolType.mqtt);

        expect(mqttProtocols.length, 1);
        expect(mqttProtocols.first.name, 'MQTT');
      });

      test('local datasource handles concurrent operations', () async {
        final protocols = List.generate(
          10,
          (i) => ProtocolModel(
            id: 'proto-$i',
            name: 'Protocol $i',
            type: ProtocolType.mqtt,
            port: 1883 + i,
          ),
        );

        await Future.wait(
          protocols.map((p) => protocolLocalDataSource.createProtocol(p)),
        );

        final all = await protocolLocalDataSource.getAllProtocols();
        expect(all.length, greaterThanOrEqualTo(10));
      });
    });

    group('ConnectionLocalDataSourceImpl', () {
      late ConnectionLocalDataSource connectionLocalDataSource;

      setUp(() {
        connectionLocalDataSource = ConnectionLocalDataSourceImpl();
      });

      test('getAllConnections returns all connections', () async {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-001',
          name: 'MQTT Broker',
          host: 'broker.example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
        );

        await connectionLocalDataSource.createConnection(connection);
        final result = await connectionLocalDataSource.getAllConnections();

        expect(result, isNotEmpty);
        expect(result.first.name, 'MQTT Broker');
      });

      test('getConnectionById returns specific connection', () async {
        final now = DateTime.now();
        const connId = 'conn-001';
        final connection = ConnectionModel(
          id: connId,
          name: 'Test Connection',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        await connectionLocalDataSource.createConnection(connection);
        final retrieved = await connectionLocalDataSource.getConnectionById(connId);

        expect(retrieved.id, connId);
        expect(retrieved.name, 'Test Connection');
      });

      test('createConnection stores connection', () async {
        final now = DateTime.now();
        final connection = ConnectionModel(
          id: 'conn-new',
          name: 'New Connection',
          host: 'new.example.com',
          port: 8883,
          status: ConnectionStatus.connecting,
          createdAt: now,
        );

        final result = await connectionLocalDataSource.createConnection(connection);

        expect(result, greaterThan(0));
      });

      test('updateConnection modifies connection status', () async {
        final now = DateTime.now();
        const connId = 'conn-001';
        final connection = ConnectionModel(
          id: connId,
          name: 'Connection',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        await connectionLocalDataSource.createConnection(connection);

        final updated = connection.copyWith(status: ConnectionStatus.active);
        await connectionLocalDataSource.updateConnection(updated);

        final retrieved = await connectionLocalDataSource.getConnectionById(connId);
        expect(retrieved.status, ConnectionStatus.active);
      });

      test('deleteConnection removes connection', () async {
        final now = DateTime.now();
        const connId = 'conn-001';
        final connection = ConnectionModel(
          id: connId,
          name: 'Connection',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        await connectionLocalDataSource.createConnection(connection);
        await connectionLocalDataSource.deleteConnection(connId);

        final all = await connectionLocalDataSource.getAllConnections();
        expect(all.where((c) => c.id == connId), isEmpty);
      });

      test('getConnectionsByStatus filters by status', () async {
        final now = DateTime.now();

        final active = ConnectionModel(
          id: 'conn-1',
          name: 'Active',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
        );

        final inactive = ConnectionModel(
          id: 'conn-2',
          name: 'Inactive',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.inactive,
          createdAt: now,
        );

        await connectionLocalDataSource.createConnection(active);
        await connectionLocalDataSource.createConnection(inactive);

        final activeConnections = await connectionLocalDataSource
            .getConnectionsByStatus(ConnectionStatus.active);

        expect(activeConnections.length, greaterThanOrEqualTo(1));
        expect(activeConnections.every((c) => c.status == ConnectionStatus.active), true);
      });
    });

    group('CertificateLocalDataSourceImpl', () {
      late CertificateLocalDataSource certificateLocalDataSource;

      setUp(() {
        certificateLocalDataSource = CertificateLocalDataSourceImpl();
      });

      test('getAllCertificates returns all certificates', () async {
        final now = DateTime.now();
        final cert = CertificateModel(
          id: 'cert-001',
          name: 'Root CA',
          type: CertificateType.ca,
          validFrom: now,
          validTo: now.add(const Duration(days: 3650)),
        );

        await certificateLocalDataSource.createCertificate(cert);
        final result = await certificateLocalDataSource.getAllCertificates();

        expect(result, isNotEmpty);
        expect(result.first.name, 'Root CA');
      });

      test('getCertificateById returns specific certificate', () async {
        final now = DateTime.now();
        const certId = 'cert-001';
        final cert = CertificateModel(
          id: certId,
          name: 'Server Cert',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        await certificateLocalDataSource.createCertificate(cert);
        final retrieved = await certificateLocalDataSource.getCertificateById(certId);

        expect(retrieved.id, certId);
        expect(retrieved.name, 'Server Cert');
      });

      test('createCertificate stores certificate', () async {
        final now = DateTime.now();
        final cert = CertificateModel(
          id: 'cert-new',
          name: 'New Cert',
          type: CertificateType.client,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        final result = await certificateLocalDataSource.createCertificate(cert);

        expect(result, greaterThan(0));
      });

      test('deleteCertificate removes certificate', () async {
        final now = DateTime.now();
        const certId = 'cert-001';
        final cert = CertificateModel(
          id: certId,
          name: 'Cert',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        await certificateLocalDataSource.createCertificate(cert);
        await certificateLocalDataSource.deleteCertificate(certId);

        final all = await certificateLocalDataSource.getAllCertificates();
        expect(all.where((c) => c.id == certId), isEmpty);
      });

      test('getExpiringCertificates returns certificates expiring soon', () async {
        final now = DateTime.now();

        final expiringSoon = CertificateModel(
          id: 'cert-1',
          name: 'Expiring',
          type: CertificateType.server,
          validFrom: now.subtract(const Duration(days: 350)),
          validTo: now.add(const Duration(days: 15)), // 15 days left
        );

        final notExpiring = CertificateModel(
          id: 'cert-2',
          name: 'Valid',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
        );

        await certificateLocalDataSource.createCertificate(expiringSoon);
        await certificateLocalDataSource.createCertificate(notExpiring);

        final expiring = await certificateLocalDataSource.getExpiringCertificates(30);

        expect(expiring.length, greaterThanOrEqualTo(1));
        expect(expiring.any((c) => c.id == 'cert-1'), true);
      });
    });

    group('LocalDataSource Database Operations', () {
      test('local datasources maintain data persistence', () async {
        final protocolDS = ProtocolLocalDataSourceImpl();

        final protocol = ProtocolModel(
          id: 'proto-persist',
          name: 'Persistent',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        // Create
        await protocolDS.createProtocol(protocol);

        // Create new instance to verify persistence
        final newInstance = ProtocolLocalDataSourceImpl();
        final retrieved = await newInstance.getProtocolById('proto-persist');

        expect(retrieved.name, 'Persistent');
      });

      test('local datasources handle transactions', () async {
        final protocolDS = ProtocolLocalDataSourceImpl();

        final protocols = [
          ProtocolModel(
            id: 'proto-t1',
            name: 'Transaction 1',
            type: ProtocolType.mqtt,
            port: 1883,
          ),
          ProtocolModel(
            id: 'proto-t2',
            name: 'Transaction 2',
            type: ProtocolType.http,
            port: 80,
          ),
        ];

        // Batch insert
        await Future.wait(
          protocols.map((p) => protocolDS.createProtocol(p)),
        );

        final all = await protocolDS.getAllProtocols();
        expect(all.length, greaterThanOrEqualTo(2));
      });
    });
  });
}
