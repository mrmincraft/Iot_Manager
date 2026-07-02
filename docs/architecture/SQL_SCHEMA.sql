-- ============================================================================
-- IoT Manager - Schéma SQL SQLite Complet
-- ============================================================================
-- Base de données pour la gestion des connexions IoT
-- Version: 1.0
-- Dernière mise à jour: 2026-06-22
-- ============================================================================

-- ============================================================================
-- 1. TABLE: protocols
-- Description: Définition des protocoles de communication IoT disponibles
-- ============================================================================
CREATE TABLE IF NOT EXISTS protocols (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK(type IN ('mqtt', 'http', 'coap', 'modbus', 'unknown')),
    description TEXT NOT NULL,
    defaultPort INTEGER NOT NULL CHECK(defaultPort > 0 AND defaultPort <= 65535),
    requiresAuthentication BOOLEAN NOT NULL DEFAULT 0,
    supportedFeatures TEXT NOT NULL, -- JSON array stored as string
    documentation TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_protocols_type ON protocols(type);
CREATE INDEX IF NOT EXISTS idx_protocols_name ON protocols(name);

-- ============================================================================
-- 2. TABLE: certificates
-- Description: Stockage des certificats SSL/TLS pour les connexions sécurisées
-- ============================================================================
CREATE TABLE IF NOT EXISTS certificates (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE,
    type TEXT NOT NULL CHECK(type IN ('ca', 'client', 'server')),
    format TEXT NOT NULL CHECK(format IN ('pem', 'der', 'p12')),
    content TEXT NOT NULL,
    password TEXT,
    validFrom TEXT,
    validUntil TEXT,
    thumbprint TEXT UNIQUE,
    isValid BOOLEAN NOT NULL DEFAULT 1,
    issuer TEXT,
    subject TEXT,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_certificates_type ON certificates(type);
CREATE INDEX IF NOT EXISTS idx_certificates_name ON certificates(name);
CREATE INDEX IF NOT EXISTS idx_certificates_isValid ON certificates(isValid);
CREATE INDEX IF NOT EXISTS idx_certificates_validUntil ON certificates(validUntil);

-- ============================================================================
-- 3. TABLE: connections
-- Description: Gestion des connexions IoT aux serveurs
-- ============================================================================
CREATE TABLE IF NOT EXISTS connections (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE,
    protocolId TEXT NOT NULL,
    host TEXT NOT NULL,
    port INTEGER NOT NULL CHECK(port > 0 AND port <= 65535),
    status TEXT NOT NULL CHECK(status IN ('active', 'inactive', 'connecting', 'error', 'disconnected')),
    useTLS BOOLEAN NOT NULL DEFAULT 0,
    certificateId TEXT,
    username TEXT,
    password TEXT,
    customSettings TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    reconnectAttempts INTEGER NOT NULL DEFAULT 3 CHECK(reconnectAttempts >= 0),
    reconnectIntervalSeconds INTEGER NOT NULL DEFAULT 5 CHECK(reconnectIntervalSeconds >= 1),
    autoReconnect BOOLEAN NOT NULL DEFAULT 1,
    lastError TEXT,
    lastConnectedAt TEXT,
    lastDisconnectedAt TEXT,
    connectionDurationSeconds INTEGER NOT NULL DEFAULT 0 CHECK(connectionDurationSeconds >= 0),
    isEnabled BOOLEAN NOT NULL DEFAULT 1,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (protocolId) REFERENCES protocols(id) ON DELETE RESTRICT,
    FOREIGN KEY (certificateId) REFERENCES certificates(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_connections_protocolId ON connections(protocolId);
CREATE INDEX IF NOT EXISTS idx_connections_certificateId ON connections(certificateId);
CREATE INDEX IF NOT EXISTS idx_connections_status ON connections(status);
CREATE INDEX IF NOT EXISTS idx_connections_name ON connections(name);
CREATE INDEX IF NOT EXISTS idx_connections_isEnabled ON connections(isEnabled);
CREATE INDEX IF NOT EXISTS idx_connections_host_port ON connections(host, port);

-- ============================================================================
-- 4. TABLE: topics
-- Description: Topics/Sujets de communication dans une connexion
-- ============================================================================
CREATE TABLE IF NOT EXISTS topics (
    id TEXT PRIMARY KEY NOT NULL,
    connectionId TEXT NOT NULL,
    name TEXT NOT NULL,
    path TEXT NOT NULL,
    qos TEXT NOT NULL CHECK(qos IN ('atMostOnce', 'atLeastOnce', 'exactlyOnce')),
    retain BOOLEAN NOT NULL DEFAULT 0,
    subscribed BOOLEAN NOT NULL DEFAULT 0,
    description TEXT,
    metadata TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    messageCount INTEGER NOT NULL DEFAULT 0 CHECK(messageCount >= 0),
    lastMessageAt TEXT,
    messageRatePerSecond INTEGER NOT NULL DEFAULT 0,
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (connectionId) REFERENCES connections(id) ON DELETE CASCADE,
    UNIQUE(connectionId, path)
);

CREATE INDEX IF NOT EXISTS idx_topics_connectionId ON topics(connectionId);
CREATE INDEX IF NOT EXISTS idx_topics_path ON topics(path);
CREATE INDEX IF NOT EXISTS idx_topics_subscribed ON topics(subscribed);
CREATE INDEX IF NOT EXISTS idx_topics_lastMessageAt ON topics(lastMessageAt);
CREATE INDEX IF NOT EXISTS idx_topics_qos ON topics(qos);

-- ============================================================================
-- 5. TABLE: messages
-- Description: Messages reçus et envoyés via les topics
-- ============================================================================
CREATE TABLE IF NOT EXISTS messages (
    id TEXT PRIMARY KEY NOT NULL,
    topicId TEXT NOT NULL,
    connectionId TEXT NOT NULL,
    direction TEXT NOT NULL CHECK(direction IN ('incoming', 'outgoing')),
    type TEXT NOT NULL CHECK(type IN ('text', 'json', 'binary', 'xml')),
    payload TEXT NOT NULL,
    payloadSize INTEGER NOT NULL CHECK(payloadSize >= 0),
    properties TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    senderIdentifier TEXT,
    receiverIdentifier TEXT,
    processed BOOLEAN NOT NULL DEFAULT 0,
    processingError TEXT,
    timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    receivedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (topicId) REFERENCES topics(id) ON DELETE CASCADE,
    FOREIGN KEY (connectionId) REFERENCES connections(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_messages_topicId ON messages(topicId);
CREATE INDEX IF NOT EXISTS idx_messages_connectionId ON messages(connectionId);
CREATE INDEX IF NOT EXISTS idx_messages_direction ON messages(direction);
CREATE INDEX IF NOT EXISTS idx_messages_type ON messages(type);
CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp);
CREATE INDEX IF NOT EXISTS idx_messages_processed ON messages(processed);
CREATE INDEX IF NOT EXISTS idx_messages_receivedAt ON messages(receivedAt);

-- ============================================================================
-- 6. TABLE: user_settings
-- Description: Paramètres utilisateur de l'application
-- ============================================================================
CREATE TABLE IF NOT EXISTS user_settings (
    id TEXT PRIMARY KEY NOT NULL,
    userId TEXT NOT NULL UNIQUE,
    themeMode TEXT NOT NULL CHECK(themeMode IN ('light', 'dark', 'system')) DEFAULT 'system',
    language TEXT NOT NULL DEFAULT 'en',
    enableNotifications BOOLEAN NOT NULL DEFAULT 1,
    enableAutoStart BOOLEAN NOT NULL DEFAULT 1,
    enableErrorReporting BOOLEAN NOT NULL DEFAULT 1,
    logLevel TEXT NOT NULL CHECK(logLevel IN ('debug', 'info', 'warning', 'error', 'critical')) DEFAULT 'info',
    logRetentionDays INTEGER NOT NULL DEFAULT 30 CHECK(logRetentionDays >= 1),
    enableLocalEncryption BOOLEAN NOT NULL DEFAULT 0,
    encryptionKey TEXT,
    messageHistoryLimit INTEGER NOT NULL DEFAULT 1000 CHECK(messageHistoryLimit >= 100),
    enableMessageFiltering BOOLEAN NOT NULL DEFAULT 1,
    uiPreferences TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_settings_userId ON user_settings(userId);
CREATE INDEX IF NOT EXISTS idx_user_settings_themeMode ON user_settings(themeMode);

-- ============================================================================
-- 7. TABLE: dashboards
-- Description: Tableaux de bord personnalisés de monitoring
-- ============================================================================
CREATE TABLE IF NOT EXISTS dashboards (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    layout TEXT NOT NULL CHECK(layout IN ('grid', 'list', 'custom')) DEFAULT 'grid',
    isDefault BOOLEAN NOT NULL DEFAULT 0,
    isActive BOOLEAN NOT NULL DEFAULT 0,
    refreshIntervalSeconds INTEGER NOT NULL DEFAULT 5 CHECK(refreshIntervalSeconds >= 1),
    layoutSettings TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_dashboards_isDefault ON dashboards(isDefault);
CREATE INDEX IF NOT EXISTS idx_dashboards_isActive ON dashboards(isActive);
CREATE INDEX IF NOT EXISTS idx_dashboards_name ON dashboards(name);

-- ============================================================================
-- 8. TABLE: dashboard_widgets
-- Description: Widgets individuels dans les tableaux de bord
-- ============================================================================
CREATE TABLE IF NOT EXISTS dashboard_widgets (
    id TEXT PRIMARY KEY NOT NULL,
    dashboardId TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('chart', 'gauge', 'table', 'log', 'status', 'custom')),
    title TEXT NOT NULL,
    connectionId TEXT,
    topicId TEXT,
    position INTEGER NOT NULL CHECK(position >= 0),
    width INTEGER NOT NULL CHECK(width > 0) DEFAULT 1,
    height INTEGER NOT NULL CHECK(height > 0) DEFAULT 1,
    configuration TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    createdAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (dashboardId) REFERENCES dashboards(id) ON DELETE CASCADE,
    FOREIGN KEY (connectionId) REFERENCES connections(id) ON DELETE SET NULL,
    FOREIGN KEY (topicId) REFERENCES topics(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_dashboardId ON dashboard_widgets(dashboardId);
CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_type ON dashboard_widgets(type);
CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_connectionId ON dashboard_widgets(connectionId);
CREATE INDEX IF NOT EXISTS idx_dashboard_widgets_topicId ON dashboard_widgets(topicId);

-- ============================================================================
-- 9. TABLE: log_entries
-- Description: Logs système et événements importants
-- ============================================================================
CREATE TABLE IF NOT EXISTS log_entries (
    id TEXT PRIMARY KEY NOT NULL,
    severity TEXT NOT NULL CHECK(severity IN ('debug', 'info', 'warning', 'error', 'critical')),
    category TEXT NOT NULL CHECK(category IN ('connection', 'message', 'device', 'system', 'security', 'performance')),
    message TEXT NOT NULL,
    details TEXT,
    stackTrace TEXT,
    userId TEXT,
    connectionId TEXT,
    topicId TEXT,
    metadata TEXT NOT NULL DEFAULT '{}', -- JSON object stored as string
    isResolved BOOLEAN NOT NULL DEFAULT 0,
    resolutionNotes TEXT,
    timestamp TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolvedAt TEXT,
    
    FOREIGN KEY (connectionId) REFERENCES connections(id) ON DELETE SET NULL,
    FOREIGN KEY (topicId) REFERENCES topics(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_log_entries_severity ON log_entries(severity);
CREATE INDEX IF NOT EXISTS idx_log_entries_category ON log_entries(category);
CREATE INDEX IF NOT EXISTS idx_log_entries_timestamp ON log_entries(timestamp);
CREATE INDEX IF NOT EXISTS idx_log_entries_isResolved ON log_entries(isResolved);
CREATE INDEX IF NOT EXISTS idx_log_entries_connectionId ON log_entries(connectionId);
CREATE INDEX IF NOT EXISTS idx_log_entries_topicId ON log_entries(topicId);
CREATE INDEX IF NOT EXISTS idx_log_entries_userId ON log_entries(userId);

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Mettre à jour updatedAt lors de la modification d'une connexion
CREATE TRIGGER IF NOT EXISTS tr_connections_update_timestamp
AFTER UPDATE ON connections
FOR EACH ROW
BEGIN
    UPDATE connections SET updatedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Trigger: Mettre à jour updatedAt lors de la modification d'un topic
CREATE TRIGGER IF NOT EXISTS tr_topics_update_timestamp
AFTER UPDATE ON topics
FOR EACH ROW
BEGIN
    UPDATE topics SET updatedAt = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Trigger: Supprimer les messages d'un topic lors de sa suppression
CREATE TRIGGER IF NOT EXISTS tr_topics_delete_cascade
AFTER DELETE ON topics
FOR EACH ROW
BEGIN
    DELETE FROM messages WHERE topicId = OLD.id;
END;

-- Trigger: Supprimer les topics et messages lors de la suppression d'une connexion
CREATE TRIGGER IF NOT EXISTS tr_connections_delete_cascade
AFTER DELETE ON connections
FOR EACH ROW
BEGIN
    DELETE FROM topics WHERE connectionId = OLD.id;
    DELETE FROM messages WHERE connectionId = OLD.id;
END;

-- ============================================================================
-- VUES UTILES
-- ============================================================================

-- Vue: Connexions actives avec leurs statistiques
CREATE VIEW IF NOT EXISTS v_active_connections_stats AS
SELECT 
    c.id,
    c.name,
    c.protocolId,
    p.name as protocolName,
    c.host,
    c.port,
    c.status,
    COUNT(DISTINCT t.id) as topicCount,
    COUNT(DISTINCT m.id) as messageCount,
    SUM(m.payloadSize) as totalPayloadSize,
    c.lastConnectedAt,
    c.connectionDurationSeconds,
    c.isEnabled
FROM connections c
LEFT JOIN protocols p ON c.protocolId = p.id
LEFT JOIN topics t ON c.id = t.connectionId
LEFT JOIN messages m ON c.id = m.connectionId
WHERE c.status = 'active'
GROUP BY c.id;

-- Vue: Topics avec dernier message
CREATE VIEW IF NOT EXISTS v_topics_with_last_message AS
SELECT 
    t.id,
    t.name,
    t.path,
    t.connectionId,
    c.name as connectionName,
    t.qos,
    t.subscribed,
    t.messageCount,
    t.lastMessageAt,
    m.direction as lastMessageDirection,
    m.type as lastMessageType,
    LENGTH(m.payload) as lastMessageSize
FROM topics t
LEFT JOIN connections c ON t.connectionId = c.id
LEFT JOIN messages m ON t.id = m.topicId AND m.id = (
    SELECT id FROM messages WHERE topicId = t.id ORDER BY receivedAt DESC LIMIT 1
);

-- Vue: Logs non résolus
CREATE VIEW IF NOT EXISTS v_unresolved_logs AS
SELECT 
    id,
    severity,
    category,
    message,
    details,
    timestamp,
    connectionId,
    topicId
FROM log_entries
WHERE isResolved = 0
ORDER BY timestamp DESC;

-- Vue: Statistiques par catégorie de log
CREATE VIEW IF NOT EXISTS v_log_statistics_by_category AS
SELECT 
    category,
    severity,
    COUNT(*) as count,
    MAX(timestamp) as lastOccurrence
FROM log_entries
GROUP BY category, severity
ORDER BY category, severity;

-- ============================================================================
-- FIN DU SCHÉMA
-- ============================================================================
