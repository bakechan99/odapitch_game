import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/texts.dart';
import '../data/local_db.dart';
import '../widgets/common_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _sessions = [];
  bool _isLoading = true;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final sessions = await LocalDb.instance.loadHistory();
    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
        _tabController?.dispose();
        if (sessions.isNotEmpty) {
          _tabController = TabController(length: sessions.length, vsync: this);
        }
      });
    }
  }

  String _formatDateTime(int millisecondsSinceEpoch) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y/$mo/$d $h:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: AppTexts.goHistory,
        onHomePressed: () => Navigator.of(context).pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : _buildHistoryContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'まだ履歴がありません',
            style: AppTextStyles.headingPrimaryMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ゲームをプレイすると\nここに記録されます',
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMutedSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    final tabController = _tabController!;

    return Column(
      children: [
        // ── タブバー（日時で識別） ──
        Container(
          color: AppColors.themePrimaryLight,
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            physics: const ClampingScrollPhysics(),
            indicatorColor: AppColors.themePrimaryDark,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.headingPrimaryMedium.copyWith(
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: List.generate(_sessions.length, (i) {
              final session = _sessions[i];
              final createdAt = session['created_at'] as int? ?? 0;
              return Tab(text: _formatDateTime(createdAt));
            }),
          ),
        ),

        // ── タブコンテンツ ──
        Expanded(
          child: TabBarView(
            controller: tabController,
            physics: const ClampingScrollPhysics(),
            children: List.generate(_sessions.length, (i) {
              return _SessionView(session: _sessions[i]);
            }),
          ),
        ),
      ],
    );
  }
}

// ─── 1セッション分の履歴表示ウィジェット ───────────────────────────────────
class _SessionView extends StatelessWidget {
  final Map<String, dynamic> session;

  const _SessionView({required this.session});

  @override
  Widget build(BuildContext context) {
    final String odaiTheme = session['odai_theme'] as String? ?? '';
    final int createdAt = session['created_at'] as int? ?? 0;
    final List players =
        (session['players'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final dateTime = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final dateLabel =
        '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // ── ヘッダー画像 ──
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.width / 3,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/GND_showResults.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ── お題 + 日時 ──
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            children: [
              Text(
                AppTexts.odaitheme(odaiTheme),
                style: AppTextStyles.headingPrimaryLarge.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(dateLabel, style: AppTextStyles.captionMuted),
            ],
          ),
        ),

        // ── プレイヤーカード一覧 ──
        ...players.map((p) {
          final playerData = p as Map<String, dynamic>;
          return _PlayerCard(playerData: playerData);
        }),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── 1プレイヤー分のカード ────────────────────────────────────────────────
class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> playerData;

  const _PlayerCard({required this.playerData});

  @override
  Widget build(BuildContext context) {
    final String playerName = playerData['player_name'] as String? ?? '';
    final String researchTitle = playerData['research_title'] as String? ?? '';
    final String aiFeedback =
        playerData['ai_feedback'] as String? ?? AppTexts.aiNoFeedback;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // プレイヤー名
            Text(
              playerName,
              style: AppTextStyles.playerName.copyWith(fontSize: 24),
            ),

            const SizedBox(height: 12),

            // 研究タイトル
            Center(
              child: Text(
                researchTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headingPrimaryLarge.copyWith(
                  fontSize: 22,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // AI フィードバックボックス
            SizedBox(
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.sectionTitle),
                    ),
                    child: Text(
                      AppTexts.aiFeedbackLabel(aiFeedback),
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    left: 12,
                    child: Container(
                      color: AppColors.surface,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        AppTexts.aiEvaluationPrefix,
                        style: AppTextStyles.headingPrimaryLarge.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
