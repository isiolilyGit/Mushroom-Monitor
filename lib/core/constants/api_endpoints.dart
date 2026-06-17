class ApiEndpoints {
  static const String _baseUrl = 'https://api.thingspeak.com';

  // ── Controlled (your original channel) ───────────────────────────────────
  static const String _controlledChannelId = '3393042';

  // ── Uncontrolled (public channel, no API key needed) ──────────────────────
  static const String _uncontrolledChannelId = '3386816';

  // Controlled URLs
  static String get controlledLastFeed =>
      '$_baseUrl/channels/$_controlledChannelId/feeds/last.json';

  static String controlledHistory(int count) =>
      '$_baseUrl/channels/$_controlledChannelId/feeds.json?results=$count';

  // Uncontrolled URLs
  static String get uncontrolledLastFeed =>
      '$_baseUrl/channels/$_uncontrolledChannelId/feeds/last.json';

  static String uncontrolledHistory(int count) =>
      '$_baseUrl/channels/$_uncontrolledChannelId/feeds.json?results=$count';
}
