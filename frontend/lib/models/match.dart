class Match {
  final int id;
  final String teamA;
  final String teamB;
  final String league;
  final DateTime matchDate;
  final String status;
  final String streamUrl;
  final bool isReplay;

  Match({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.league,
    required this.matchDate,
    required this.status,
    required this.streamUrl,
    required this.isReplay,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      teamA: json['team_a'],
      teamB: json['team_b'],
      league: json['league'],
      matchDate: DateTime.parse(json['match_date']),
      status: json['status'],
      streamUrl: json['stream_url'] ?? '',
      isReplay: json['is_replay'] == 1 || json['is_replay'] == true,
    );
  }

  String get matchTitle => '$teamA vs $teamB';

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(matchDate);

    if (difference.inDays == 0) {
      return 'Today, ${matchDate.hour.toString().padLeft(2, '0')}:${matchDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${matchDate.hour.toString().padLeft(2, '0')}:${matchDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${matchDate.day}/${matchDate.month}/${matchDate.year}';
    }
  }
}
