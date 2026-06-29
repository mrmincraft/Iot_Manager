import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service de gestion de la base de données SQLite
/// Responsable de l'initialisation, des migrations et de l'accès à la DB
class DatabaseService {
  static const String _dbName = 'iot_manager.db';
  static const int _dbVersion = 1;
  
  static Database? _database;
  
  /// Obtenir l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialiser la base de données
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Créer les tables au premier lancement
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }
  
  /// Gérer les migrations de schéma
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // Migrations futures si nécessaire
      // À implémenter selon les besoins
    }
  }
  
  /// Créer toutes les tables
  Future<void> _createTables(Database db) async {
    // Table: protocols
    await db.execute('''
      CREATE TABLE protocols (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('mqtt', 'http', 'coap', 'modbus', 'unknown')),
        description TEXT,
        defaultPort INTEGER CHECK(defaultPort >= 1 AND defaultPort <= 65535),
        requiresAuthentication INTEGER NOT NULL DEFAULT 0,
        supportedFeatures TEXT,
        documentation TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Table: certificates
    await db.execute('''
      CREATE TABLE certificates (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('ca', 'client', 'server')),
        format TEXT NOT NULL CHECK(format IN ('pem', 'der', 'p12')),
        content TEXT NOT NULL,
        password TEXT,
        validFrom TEXT,
        validUntil TEXT,
        thumbprint TEXT UNIQUE,
        isValid INTEGER NOT NULL DEFAULT 1,
        issuer TEXT,
        subject TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Table: connections
    await db.execute('''
      CREATE TABLE connections (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        protocolId TEXT NOT NULL,
        host TEXT NOT NULL,
        port INTEGER NOT NULL CHECK(port >= 1 AND port <= 65535),
        status TEXT NOT NULL CHECK(status IN ('active', 'inactive', 'connecting', 'error', 'disconnected')),
        useTLS INTEGER NOT NULL DEFAULT 0,
        certificateId TEXT,
        username TEXT,
        password TEXT,
        customSettings TEXT,
        reconnectAttempts INTEGER NOT NULL DEFAULT 3,
        reconnectIntervalSeconds INTEGER NOT NULL CHECK(reconnectIntervalSeconds >= 1),
        autoReconnect INTEGER NOT NULL DEFAULT 1,
        lastError TEXT,
        lastConnectedAt TEXT,
        lastDisconnectedAt TEXT,
        connectionDurationSeconds INTEGER NOT NULL DEFAULT 0,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY(protocolId) REFERENCES protocols(id) ON DELETE RESTRICT,
        FOREIGN KEY(certificateId) REFERENCES certificates(id) ON DELETE SET NULL
      )
    ''');
    
    // Table: topics
    await db.execute('''
      CREATE TABLE topics (
        id TEXT PRIMARY KEY,
        connectionId TEXT NOT NULL,
        name TEXT NOT NULL,
        path TEXT NOT NULL,
        qos TEXT NOT NULL CHECK(qos IN ('atMostOnce', 'atLeastOnce', 'exactlyOnce')),
        retain INTEGER NOT NULL DEFAULT 0,
        subscribed INTEGER NOT NULL DEFAULT 0,
        description TEXT,
        metadata TEXT,
        messageCount INTEGER NOT NULL DEFAULT 0,
        lastMessageAt TEXT,
        messageRatePerSecond REAL NOT NULL DEFAULT 0.0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY(connectionId) REFERENCES connections(id) ON DELETE CASCADE,
        UNIQUE(connectionId, path)
      )
    ''');
    
    // Table: messages
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        topicId TEXT NOT NULL,
        connectionId TEXT NOT NULL,
        direction TEXT NOT NULL CHECK(direction IN ('incoming', 'outgoing')),
        type TEXT NOT NULL CHECK(type IN ('text', 'json', 'binary', 'xml')),
        payload TEXT NOT NULL,
        payloadSize INTEGER NOT NULL CHECK(payloadSize >= 0),
        properties TEXT,
        senderIdentifier TEXT,
        receiverIdentifier TEXT,
        processed INTEGER NOT NULL DEFAULT 0,
        processingError TEXT,
        timestamp TEXT NOT NULL,
        receivedAt TEXT NOT NULL,
        FOREIGN KEY(topicId) REFERENCES topics(id) ON DELETE CASCADE,
        FOREIGN KEY(connectionId) REFERENCES connections(id) ON DELETE CASCADE
      )
    ''');
    
    // Table: user_settings
    await db.execute('''
      CREATE TABLE user_settings (
        id TEXT PRIMARY KEY,
        userId TEXT UNIQUE NOT NULL,
        themeMode TEXT NOT NULL CHECK(themeMode IN ('light', 'dark', 'system')),
        language TEXT NOT NULL DEFAULT 'en',
        enableNotifications INTEGER NOT NULL DEFAULT 1,
        enableAutoStart INTEGER NOT NULL DEFAULT 0,
        enableErrorReporting INTEGER NOT NULL DEFAULT 1,
        logLevel TEXT NOT NULL CHECK(logLevel IN ('debug', 'info', 'warning', 'error', 'critical')),
        logRetentionDays INTEGER NOT NULL CHECK(logRetentionDays >= 1),
        enableLocalEncryption INTEGER NOT NULL DEFAULT 0,
        encryptionKey TEXT,
        messageHistoryLimit INTEGER NOT NULL CHECK(messageHistoryLimit >= 100),
        enableMessageFiltering INTEGER NOT NULL DEFAULT 0,
        uiPreferences TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Table: dashboards
    await db.execute('''
      CREATE TABLE dashboards (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        description TEXT,
        layout TEXT NOT NULL CHECK(layout IN ('grid', 'list', 'custom')),
        widgets TEXT NOT NULL,
        isDefault INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 0,
        refreshIntervalSeconds INTEGER NOT NULL CHECK(refreshIntervalSeconds >= 1),
        layoutSettings TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    
    // Table: log_entries
    await db.execute('''
      CREATE TABLE log_entries (
        id TEXT PRIMARY KEY,
        severity TEXT NOT NULL CHECK(severity IN ('debug', 'info', 'warning', 'error', 'critical')),
        category TEXT NOT NULL CHECK(category IN ('connection', 'message', 'device', 'system', 'security', 'performance')),
        message TEXT NOT NULL,
        details TEXT,
        stackTrace TEXT,
        userId TEXT,
        connectionId TEXT,
        topicId TEXT,
        metadata TEXT,
        isResolved INTEGER NOT NULL DEFAULT 0,
        resolutionNotes TEXT,
        timestamp TEXT NOT NULL,
        resolvedAt TEXT,
        FOREIGN KEY(connectionId) REFERENCES connections(id) ON DELETE SET NULL,
        FOREIGN KEY(topicId) REFERENCES topics(id) ON DELETE SET NULL
      )
    ''');
    
    // Créer les indexes
    await _createIndexes(db);
    
    // Créer les vues
    await _createViews(db);
  }
  
  /// Créer les indexes pour optimiser les requêtes
  Future<void> _createIndexes(Database db) async {
    // Protocols
    await db.execute('CREATE INDEX idx_protocols_type ON protocols(type)');
    
    // Certificates
    await db.execute('CREATE INDEX idx_certificates_type ON certificates(type)');
    
    // Connections
    await db.execute('CREATE INDEX idx_connections_protocolId ON connections(protocolId)');
    await db.execute('CREATE INDEX idx_connections_certificateId ON connections(certificateId)');
    await db.execute('CREATE INDEX idx_connections_status ON connections(status)');
    await db.execute('CREATE INDEX idx_connections_isEnabled ON connections(isEnabled)');
    
    // Topics
    await db.execute('CREATE INDEX idx_topics_connectionId ON topics(connectionId)');
    await db.execute('CREATE INDEX idx_topics_subscribed ON topics(subscribed)');
    
    // Messages
    await db.execute('CREATE INDEX idx_messages_topicId ON messages(topicId)');
    await db.execute('CREATE INDEX idx_messages_connectionId ON messages(connectionId)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_messages_processed ON messages(processed)');
    await db.execute('CREATE INDEX idx_messages_direction ON messages(direction)');
    
    // LogEntries
    await db.execute('CREATE INDEX idx_logs_severity ON log_entries(severity)');
    await db.execute('CREATE INDEX idx_logs_category ON log_entries(category)');
    await db.execute('CREATE INDEX idx_logs_timestamp ON log_entries(timestamp)');
    await db.execute('CREATE INDEX idx_logs_isResolved ON log_entries(isResolved)');
    await db.execute('CREATE INDEX idx_logs_connectionId ON log_entries(connectionId)');
  }
  
  /// Créer les vues pour faciliter les requêtes complexes
  Future<void> _createViews(Database db) async {
    // Vue: connexions actives avec statistiques
    await db.execute('''
      CREATE VIEW active_connections_stats AS
      SELECT 
        c.id,
        c.name,
        c.status,
        COUNT(DISTINCT t.id) as topicCount,
        COUNT(DISTINCT m.id) as messageCount,
        MAX(m.timestamp) as lastMessageTime
      FROM connections c
      LEFT JOIN topics t ON c.id = t.connectionId
      LEFT JOIN messages m ON c.id = m.connectionId
      WHERE c.isEnabled = 1 AND c.status = 'active'
      GROUP BY c.id
    ''');
    
    // Vue: topics avec dernier message
    await db.execute('''
      CREATE VIEW topics_with_last_message AS
      SELECT 
        t.id,
        t.name,
        t.path,
        t.messageCount,
        m.id as lastMessageId,
        m.payload as lastMessagePayload,
        m.timestamp as lastMessageTime
      FROM topics t
      LEFT JOIN messages m ON t.id = m.topicId
        AND m.timestamp = (
          SELECT MAX(timestamp) FROM messages WHERE topicId = t.id
        )
    ''');
    
    // Vue: logs non résolus
    await db.execute('''
      CREATE VIEW unresolved_logs AS
      SELECT 
        id,
        severity,
        category,
        message,
        timestamp
      FROM log_entries
      WHERE isResolved = 0
      ORDER BY timestamp DESC
    ''');
    
    // Vue: statistiques des logs par catégorie
    await db.execute('''
      CREATE VIEW log_statistics_by_category AS
      SELECT 
        category,
        severity,
        COUNT(*) as count,
        MAX(timestamp) as lastOccurrence
      FROM log_entries
      GROUP BY category, severity
    ''');
  }
  
  /// Fermer la base de données
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  /// Supprimer la base de données (pour les tests)
  Future<void> delete() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    await deleteDatabase(path);
    _database = null;
  }
}
