import 'app_user.dart';
import 'api_client.dart';

/// Replaces the three raw Firestore DocumentSnapshot/QuerySnapshot objects
/// wallet_stream.dart used to combine (wallet doc, user doc, top-10
/// leaderboard query) with one typed, REST-backed bundle.
class DashboardData {
  final AppUser user;
  final Map<String, dynamic> wallet; // raw WalletResponse JSON — see ApiClient.getWalletBalance
  final String kycStatus; // not_submitted | pending | approved | rejected
  final int ongoingTasks;
  final int completedTasks;
  final int missedTasks;
  final int referralCount;
  final int totalReferralEarningsKobo;
  final int gritLevel;
  final int gritTasksToNextLevel;
  final List<LeaderboardEntry> leaderboardTop;

  DashboardData({
    required this.user,
    required this.wallet,
    required this.kycStatus,
    required this.ongoingTasks,
    required this.completedTasks,
    required this.missedTasks,
    required this.referralCount,
    required this.totalReferralEarningsKobo,
    required this.gritLevel,
    required this.gritTasksToNextLevel,
    required this.leaderboardTop,
  });
}

class LeaderboardEntry {
  final String fullName;
  final num score;
  LeaderboardEntry({required this.fullName, required this.score});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        fullName: json['full_name'] as String? ?? 'Unnamed',
        score: (json['total_score'] as num?) ?? 0,
      );
}

/// Backend has no push/real-time channel yet (see docs/architecture.md —
/// SSE/WebSocket is a documented future step), so this polls every
/// [interval] instead of the instant Firestore .snapshots() updates the
/// app used to get. 20s balances "feels reasonably live" against not
/// hammering the API; tighten it later if a real-time channel lands.
Stream<DashboardData> dashboardStream({Duration interval = const Duration(seconds: 20)}) async* {
  final api = ApiClient.instance;
  while (true) {
    try {
      final results = await Future.wait([
        api.me(),
        api.getWalletBalance(),
        api.kycStatus(),
      ]);
      final user = results[0] as AppUser;
      final wallet = results[1] as Map<String, dynamic>;
      final kycStatus = results[2] as String;

      final stats = await api.myTaskStats();
      final referral = await api.referralStats();
      final leaderboard = await api.leaderboard('weekly');
      final rewards = await api.rewardsProgress();

      yield DashboardData(
        user: user,
        wallet: wallet,
        kycStatus: kycStatus,
        ongoingTasks: stats['ongoing_tasks'] as int? ?? 0,
        completedTasks: stats['completed_tasks'] as int? ?? 0,
        missedTasks: stats['missed_tasks'] as int? ?? 0,
        referralCount: referral['referral_count'] as int? ?? 0,
        totalReferralEarningsKobo: referral['total_referral_earnings_kobo'] as int? ?? 0,
        gritLevel: rewards['grit_level'] as int? ?? 1,
        gritTasksToNextLevel: rewards['grit_tasks_to_next_level'] as int? ?? 20,
        leaderboardTop: (leaderboard as List)
            .take(3)
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      // Swallow and retry next tick rather than tearing down the stream —
      // a transient network blip shouldn't kill the whole dashboard;
      // StreamBuilder just keeps showing the last good snapshot.
    }
    await Future.delayed(interval);
  }
}
