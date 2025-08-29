import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/game_service.dart';
import '../features/leader_feature.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _gameService = GameService();

  String? _currentUserName;

  final List<String> backgrounds = [
    'assets/bg/tugak_bgSmallFlag.PNG',
    'assets/bg/tugak_bgSmallFlag.PNG',
    'assets/bg/card_bgSmallFlag.PNG',
    'assets/bg/boat_bgSmallFlag.PNG',
  ];

  late Future<List<LeaderboardEntry>> _overallFuture;
  late Future<List<LeaderboardEntry>> _siglulungFuture;
  late Future<List<LeaderboardEntry>> _tugakFuture;
  late Future<List<LeaderboardEntry>> _mitutuglungFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() => setState(() {}));

    _overallFuture = _gameService.getOverallLeaderboard(limit: 10);
    _siglulungFuture = _gameService.getGameLeaderboard(
        gameType: 'siglulung_bangka', limit: 10);
    _tugakFuture =
        _gameService.getGameLeaderboard(gameType: 'tugak_catching', limit: 10);
    _mitutuglungFuture =
        _gameService.getGameLeaderboard(gameType: 'mitutuglung', limit: 10);

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;

    if (user == null) {
      setState(() {
        _currentUserName = "Guest";
      });
      return;
    }

    try {
      final record = await client
          .from('users')
          .select('user_name')
          .eq('auth_id', user.id)
          .maybeSingle();

      setState(() {
        _currentUserName = record?['user_name'] ?? "Guest";
      });
    } catch (e) {
      debugPrint("Error loading current user: $e");
      setState(() {
        _currentUserName = "Guest";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgrounds[_tabController.index];
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final safeHeight = size.height - mq.padding.vertical;

    final contentWidth = (size.width * 0.68).clamp(280.0, 960.0);
    final tabFontSize = (size.width / 1280 * 12).clamp(10.0, 16.0);
    final gap = (size.height * 0.012).clamp(6.0, 16.0);

    final tabWShort = (size.width * 0.16).clamp(88.0, 220.0);
    final tabWLong = (size.width * 0.20).clamp(100.0, 260.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(bg, fit: BoxFit.cover)),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TabBar
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xAD572100),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xAD572100),
                          width: 2,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: const Color(0xF9DD9A00),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xAD572100),
                            width: 2,
                          ),
                        ),
                        labelStyle: TextStyle(
                          fontSize: tabFontSize,
                          fontWeight: FontWeight.w700,
                        ),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.white,
                        tabs: [
                          SizedBox(
                              width: tabWShort,
                              child: const Tab(text: 'Overall')),
                          SizedBox(
                              width: tabWShort,
                              child: const Tab(text: 'Tugak')),
                          SizedBox(
                              width: tabWLong,
                              child: const Tab(text: 'Mitutuglung')),
                          SizedBox(
                              width: tabWLong,
                              child: const Tab(text: 'Siglulung')),
                        ],
                      ),
                    ),
                    SizedBox(height: gap),
                    // Content
                    SizedBox(
                      height: (safeHeight * 0.48).clamp(220.0, 440.0),
                      child: Container(
                        padding: EdgeInsets.all(
                            (size.width * 0.022).clamp(10.0, 24.0)),
                        decoration: BoxDecoration(
                          color: const Color(0xF9DD9A00),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xAD572100),
                            width: 4,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _Scrollable(
                              child: FutureBuilder<List<LeaderboardEntry>>(
                                future: _overallFuture,
                                builder: _buildLeaderboard(
                                  (entries) => MacroLeaderboardTable(
                                    entries: entries,
                                    currentUserName:
                                        _currentUserName ?? 'Guest',
                                  ),
                                ),
                              ),
                            ),
                            _Scrollable(
                              child: FutureBuilder<List<LeaderboardEntry>>(
                                future: _tugakFuture,
                                builder: _buildLeaderboard(
                                  (entries) => GameLeaderboardTable(
                                    gameTitle: "Tugak Catching",
                                    entries: entries,
                                    currentUserName:
                                        _currentUserName ?? 'Guest',
                                  ),
                                ),
                              ),
                            ),
                            _Scrollable(
                              child: FutureBuilder<List<LeaderboardEntry>>(
                                future: _mitutuglungFuture,
                                builder: _buildLeaderboard(
                                  (entries) => GameLeaderboardTable(
                                    gameTitle: "Mitutuglung",
                                    entries: entries,
                                    currentUserName:
                                        _currentUserName ?? 'Guest',
                                  ),
                                ),
                              ),
                            ),
                            _Scrollable(
                              child: FutureBuilder<List<LeaderboardEntry>>(
                                future: _siglulungFuture,
                                builder: _buildLeaderboard(
                                  (entries) => GameLeaderboardTable(
                                    gameTitle: "Siglulung Bangka",
                                    entries: entries,
                                    currentUserName:
                                        _currentUserName ?? 'Guest',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget Function(BuildContext, AsyncSnapshot<List<LeaderboardEntry>>)
      _buildLeaderboard(Widget Function(List<LeaderboardEntry>) builder) {
    return (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text("No leaderboard data yet.");
      }
      return builder(snapshot.data!);
    };
  }
}

class _Scrollable extends StatelessWidget {
  final Widget child;
  const _Scrollable({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: child,
        ),
      ),
    );
  }
}
