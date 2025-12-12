import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streaming_bola_app/services/auth_service.dart';
import 'package:streaming_bola_app/services/api_service.dart';
import 'package:streaming_bola_app/models/match.dart';
import 'package:streaming_bola_app/widgets/match_card.dart';
import 'package:streaming_bola_app/widgets/video_player.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Match> _liveMatches = [];
  List<Match> _replayMatches = [];
  List<Match> _allMatches = [];
  List<Match> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() => _isLoading = true);

    try {
      final [live, replay, all] = await Future.wait([
        _apiService.getLiveMatches(),
        _apiService.getReplayMatches(),
        _apiService.getMatches(),
      ]);

      setState(() {
        _liveMatches = live;
        _replayMatches = replay;
        _allMatches = all;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Gagal memuat data: $e');
    }
  }

  Future<void> _searchMatches(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _apiService.searchMatches(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      _showError('Gagal mencari: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _logout() {
    Provider.of<AuthService>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('STREAMING BOLA'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMatches,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'LIVE', icon: Icon(Icons.live_tv)),
            Tab(text: 'REPLAY', icon: Icon(Icons.replay)),
            Tab(text: 'SEMUA', icon: Icon(Icons.list)),
          ],
          indicatorColor: const Color(0xFF1A73E8),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Cari pertandingan...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _searchMatches(value),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _searchMatches('');
                      },
                    ),
                ],
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A73E8)),
                ),
              ),
            )
          else
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMatchList(
                            _liveMatches, 'Tidak ada pertandingan live'),
                        _buildMatchList(
                            _replayMatches, 'Tidak ada replay tersedia'),
                        _buildMatchList(_allMatches, 'Tidak ada pertandingan'),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<Match> matches, String emptyMessage) {
    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      backgroundColor: const Color(0xFF1A1A1A),
      color: const Color(0xFF1A73E8),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return MatchCard(
            match: match,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    match: match,
                    onWatchComplete: () {
                      final user =
                          Provider.of<AuthService>(context, listen: false)
                              .currentUser;
                      if (user != null) {
                        _apiService.addToHistory(user.id, match.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Text(
          'Tidak ditemukan pertandingan',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final match = _searchResults[index];
        return MatchCard(
          match: match,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  match: match,
                  onWatchComplete: () {
                    final user =
                        Provider.of<AuthService>(context, listen: false)
                            .currentUser;
                    if (user != null) {
                      _apiService.addToHistory(user.id, match.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
