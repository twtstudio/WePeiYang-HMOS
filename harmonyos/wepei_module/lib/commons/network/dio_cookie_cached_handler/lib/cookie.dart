class Cookie {
  final String name;
  final String value;
  final DateTime expires;
  final String domain;

  const Cookie({
    required this.name,
    required this.value,
    required this.expires,
    required this.domain,
  });

  @override
  int get hashCode => Object.hash(name, domain);

  @override
  bool operator ==(Object other) =>
      other is Cookie && other.name == name && other.domain == domain;
}
