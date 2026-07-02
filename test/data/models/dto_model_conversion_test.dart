import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:iot_manager/data/models/protocol_model.dart';
import 'package:iot_manager/data/models/connection_model.dart';
import 'package:iot_manager/data/models/certificate_model.dart';
import 'package:iot_manager/data/dtos/protocol_dto.dart';
import 'package:iot_manager/data/dtos/connection_dto.dart';
import 'package:iot_manager/data/dtos/certificate_dto.dart';
import 'package:iot_manager/domain/entities/protocol.dart';
import 'package:iot_manager/domain/entities/connection.dart';
import 'package:iot_manager/domain/entities/certificate.dart';

void main() {
  group('Data Layer - DTO and Model Tests', () {
    group('ProtocolDTO Conversion', () {
      test('ProtocolDTO.fromEntity creates DTO from entity', () {
        final entity = Protocol(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
          description: 'Message Queuing Telemetry Transport',
          metadata: {'version': '5.0'},
        );

        final dto = ProtocolDTO.fromEntity(entity);

        expect(dto.id, 'proto-001');
        expect(dto.name, 'MQTT');
        expect(dto.port, 1883);
        expect(dto.description, 'Message Queuing Telemetry Transport');
      });

      test('ProtocolDTO.toEntity creates entity from DTO', () {
        final dto = ProtocolDTO(
          id: 'proto-001',
          name: 'HTTP',
          type: ProtocolType.http,
          port: 80,
        );

        final entity = dto.toEntity();

        expect(entity.id, 'proto-001');
        expect(entity.name, 'HTTP');
        expect(entity.type, ProtocolType.http);
        expect(entity.port, 80);
      });

      test('ProtocolDTO converts type enum correctly', () {
        final types = [
          ProtocolType.mqtt,
          ProtocolType.http,
          ProtocolType.coap,
          ProtocolType.modbus,
        ];

        for (final type in types) {
          final dto = ProtocolDTO(
            id: 'test',
            name: 'Test',
            type: type,
            port: 1234,
          );

          expect(dto.toEntity().type, type);
        }
      });

      test('ProtocolDTO.fromJSON deserializes correctly', () {
        final json = {
          'id': 'proto-001',
          'name': 'MQTT',
          'type': 'mqtt',
          'port': 1883,
          'description': 'MQTT Protocol',
          'metadata': {},
        };

        final dto = ProtocolDTO.fromJSON(json);

        expect(dto.id, 'proto-001');
        expect(dto.name, 'MQTT');
        expect(dto.port, 1883);
      });

      test('ProtocolDTO.toJSON serializes correctly', () {
        final dto = ProtocolDTO(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final json = dto.toJSON();

        expect(json['id'], 'proto-001');
        expect(json['name'], 'MQTT');
        expect(json['port'], 1883);
      });

      test('ProtocolDTO round-trip conversion preserves data', () {
        final original = Protocol(
          id: 'proto-001',
          name: 'CoAP',
          type: ProtocolType.coap,
          port: 5683,
          description: 'Constrained Application Protocol',
        );

        final dto = ProtocolDTO.fromEntity(original);
        final converted = dto.toEntity();

        expect(converted.id, original.id);
        expect(converted.name, original.name);
        expect(converted.type, original.type);
        expect(converted.port, original.port);
      });
    });

    group('ConnectionDTO Conversion', () {
      test('ConnectionDTO.fromEntity creates DTO from entity', () {
        final now = DateTime.now();
        final entity = Connection(
          id: 'conn-001',
          name: 'MQTT Broker',
          host: 'broker.example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
        );

        final dto = ConnectionDTO.fromEntity(entity);

        expect(dto.id, 'conn-001');
        expect(dto.name, 'MQTT Broker');
        expect(dto.host, 'broker.example.com');
        expect(dto.port, 1883);
      });

      test('ConnectionDTO converts status enum correctly', () {
        final statuses = [
          ConnectionStatus.active,
          ConnectionStatus.inactive,
          ConnectionStatus.connecting,
          ConnectionStatus.failed,
        ];

        final now = DateTime.now();

        for (final status in statuses) {
          final dto = ConnectionDTO(
            id: 'test',
            name: 'Test',
            host: 'example.com',
            port: 1883,
            status: status,
            createdAt: now,
          );

          expect(dto.toEntity().status, status);
        }
      });

      test('ConnectionDTO stores credentials safely', () {
        final now = DateTime.now();
        final dto = ConnectionDTO(
          id: 'conn-001',
          name: 'Secure Connection',
          host: 'example.com',
          port: 8883,
          status: ConnectionStatus.inactive,
          createdAt: now,
          username: 'admin',
          password: 'secret123',
        );

        final entity = dto.toEntity();

        expect(entity.username, 'admin');
        expect(entity.password, 'secret123');
      });
    });

    group('CertificateDTO Conversion', () {
      test('CertificateDTO.fromEntity creates DTO from entity', () {
        final now = DateTime.now();
        final entity = Certificate(
          id: 'cert-001',
          name: 'Root CA',
          type: CertificateType.ca,
          validFrom: now,
          validTo: now.add(const Duration(days: 3650)),
        );

        final dto = CertificateDTO.fromEntity(entity);

        expect(dto.id, 'cert-001');
        expect(dto.name, 'Root CA');
        expect(dto.type, CertificateType.ca);
      });

      test('CertificateDTO converts type enum correctly', () {
        final types = [
          CertificateType.ca,
          CertificateType.server,
          CertificateType.client,
        ];

        final now = DateTime.now();

        for (final type in types) {
          final dto = CertificateDTO(
            id: 'test',
            name: 'Test',
            type: type,
            validFrom: now,
            validTo: now.add(const Duration(days: 365)),
          );

          expect(dto.toEntity().type, type);
        }
      });

      test('CertificateDTO stores PEM content', () {
        final now = DateTime.now();
        const pemContent =
            '-----BEGIN CERTIFICATE-----\nMIIC...\n-----END CERTIFICATE-----';

        final dto = CertificateDTO(
          id: 'cert-001',
          name: 'Test Cert',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
          content: pemContent,
        );

        final entity = dto.toEntity();

        expect(entity.content, pemContent);
      });

      test('CertificateDTO stores fingerprint', () {
        final now = DateTime.now();
        const fingerprint = 'sha256:abc123def456';

        final dto = CertificateDTO(
          id: 'cert-001',
          name: 'Test Cert',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
          fingerprint: fingerprint,
        );

        final entity = dto.toEntity();

        expect(entity.fingerprint, fingerprint);
      });
    });

    group('ProtocolModel Conversion', () {
      test('ProtocolModel converts to entity correctly', () {
        final model = ProtocolModel(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final entity = model.toEntity();

        expect(entity.id, 'proto-001');
        expect(entity.name, 'MQTT');
        expect(entity.port, 1883);
      });

      test('ProtocolModel fromEntity creates correct model', () {
        final entity = Protocol(
          id: 'proto-001',
          name: 'HTTP',
          type: ProtocolType.http,
          port: 80,
        );

        final model = ProtocolModel.fromEntity(entity);

        expect(model.id, 'proto-001');
        expect(model.name, 'HTTP');
        expect(model.port, 80);
      });

      test('ProtocolModel maps type enums', () {
        final mqtt = ProtocolModel(
          id: 'p1',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
        );

        final coap = ProtocolModel(
          id: 'p2',
          name: 'CoAP',
          type: ProtocolType.coap,
          port: 5683,
        );

        expect(mqtt.toEntity().type, ProtocolType.mqtt);
        expect(coap.toEntity().type, ProtocolType.coap);
      });
    });

    group('ConnectionModel Conversion', () {
      test('ConnectionModel converts to entity correctly', () {
        final now = DateTime.now();
        final model = ConnectionModel(
          id: 'conn-001',
          name: 'MQTT Broker',
          host: 'broker.example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
        );

        final entity = model.toEntity();

        expect(entity.id, 'conn-001');
        expect(entity.name, 'MQTT Broker');
        expect(entity.status, ConnectionStatus.active);
      });

      test('ConnectionModel maps status enums', () {
        final now = DateTime.now();

        final active = ConnectionModel(
          id: 'c1',
          name: 'Active',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
        );

        final failed = ConnectionModel(
          id: 'c2',
          name: 'Failed',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.failed,
          createdAt: now,
        );

        expect(active.toEntity().status, ConnectionStatus.active);
        expect(failed.toEntity().status, ConnectionStatus.failed);
      });
    });

    group('CertificateModel Conversion', () {
      test('CertificateModel converts to entity correctly', () {
        final now = DateTime.now();
        final model = CertificateModel(
          id: 'cert-001',
          name: 'Root CA',
          type: CertificateType.ca,
          validFrom: now,
          validTo: now.add(const Duration(days: 3650)),
        );

        final entity = model.toEntity();

        expect(entity.id, 'cert-001');
        expect(entity.name, 'Root CA');
        expect(entity.type, CertificateType.ca);
      });

      test('CertificateModel tracks validity dates', () {
        final validFrom = DateTime(2024, 1, 1);
        final validTo = DateTime(2026, 1, 1);

        final model = CertificateModel(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: validFrom,
          validTo: validTo,
        );

        final entity = model.toEntity();

        expect(entity.validFrom, validFrom);
        expect(entity.validTo, validTo);
      });
    });

    group('Data Type Serialization', () {
      test('Protocol metadata serialization', () {
        final dto = ProtocolDTO(
          id: 'proto-001',
          name: 'MQTT',
          type: ProtocolType.mqtt,
          port: 1883,
          metadata: {
            'version': '5.0',
            'keepalive': 60,
            'tlsEnabled': true,
          },
        );

        final json = dto.toJSON();

        expect(json['metadata']['version'], '5.0');
        expect(json['metadata']['keepalive'], 60);
        expect(json['metadata']['tlsEnabled'], true);
      });

      test('Connection metadata serialization', () {
        final now = DateTime.now();
        final dto = ConnectionDTO(
          id: 'conn-001',
          name: 'Test',
          host: 'example.com',
          port: 1883,
          status: ConnectionStatus.active,
          createdAt: now,
          metadata: {
            'tlsVersion': '1.3',
            'cipherSuite': 'TLS_AES_256_GCM_SHA384',
          },
        );

        final json = dto.toJSON();

        expect(json['metadata']['tlsVersion'], '1.3');
      });

      test('Certificate metadata serialization', () {
        final now = DateTime.now();
        final dto = CertificateDTO(
          id: 'cert-001',
          name: 'Test',
          type: CertificateType.server,
          validFrom: now,
          validTo: now.add(const Duration(days: 365)),
          metadata: {
            'algorithm': 'RSA',
            'keySize': 2048,
          },
        );

        final json = dto.toJSON();

        expect(json['metadata']['algorithm'], 'RSA');
        expect(json['metadata']['keySize'], 2048);
      });
    });
  });
}
