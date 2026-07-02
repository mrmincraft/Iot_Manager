/// Metadata about a plugin including version, dependencies, and configuration
class PluginMetadata {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final List<String> dependencies;
  final Map<String, dynamic> configSchema;
  final Map<String, dynamic> tags;

  PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    this.dependencies = const [],
    this.configSchema = const {},
    this.tags = const {},
  });

  /// Check if this version is compatible with required version
  bool isVersionCompatible(String requiredVersion) {
    final parts = version.split('.');
    final requiredParts = requiredVersion.split('.');

    if (parts.length < 2 || requiredParts.length < 2) {
      return version == requiredVersion;
    }

    final major = int.tryParse(parts[0]) ?? 0;
    final requiredMajor = int.tryParse(requiredParts[0]) ?? 0;

    return major == requiredMajor;
  }

  /// Convert metadata to JSON-compatible map
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'version': version,
    'author': author,
    'description': description,
    'dependencies': dependencies,
    'configSchema': configSchema,
    'tags': tags,
  };

  /// Create metadata from JSON-compatible map
  factory PluginMetadata.fromMap(Map<String, dynamic> map) => PluginMetadata(
    id: map['id'] as String,
    name: map['name'] as String,
    version: map['version'] as String,
    author: map['author'] as String,
    description: map['description'] as String,
    dependencies: List<String>.from(map['dependencies'] as List? ?? []),
    configSchema: map['configSchema'] as Map<String, dynamic>? ?? {},
    tags: map['tags'] as Map<String, dynamic>? ?? {},
  );

  @override
  String toString() => 'PluginMetadata($id v$version by $author)';
}
