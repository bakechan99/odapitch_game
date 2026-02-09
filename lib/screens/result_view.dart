import 'package:flutter/material.dart';
import '../models/player.dart';
import '../constants/texts.dart';

class ResultView extends StatelessWidget {
  final List<Player> players;
  final Map<int, Map<int, int>> voteMatrix;
  final Color Function(int) getPlayerColor;
  final VoidCallback onHomePressed;

  const ResultView({
    super.key,
    required this.players,
    required this.voteMatrix,
    required this.getPlayerColor,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> results = [];
    for (int i = 0; i < players.length; i++) {
      int total = 0;
      Map<int, int> breakdown = voteMatrix[i] ?? {};
      breakdown.forEach((_, amount) => total += amount);
      results.add({'player': players[i], 'total': total, 'breakdown': breakdown});
    }
    results.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    final int maxPossibleTotal = players.length * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.resultTitle),
        automaticallyImplyLeading: false,
        leading: IconButton(icon: const Icon(Icons.home), onPressed: onHomePressed),
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(20.0), child: Text(AppTexts.resultHeader, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final data = results[index];
                final player = data['player'] as Player;
                final int total = data['total'] as int;
                final Map<int, int> breakdown = data['breakdown'] as Map<int, int>;

                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (index == 0) const Text("🥇 ", style: TextStyle(fontSize: 24)),
                            if (index == 1) const Text("🥈 ", style: TextStyle(fontSize: 24)),
                            if (index == 2) const Text("🥉 ", style: TextStyle(fontSize: 24)),
                            Text("${index + 1}位", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(player.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  Text(player.researchTitle, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Text("$total 万円", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 30,
                            color: Colors.grey[200],
                            child: Row(
                              children: [
                                Expanded(
                                  flex: total,
                                  child: total > 0
                                      ? Row(
                                          children: breakdown.entries.map((entry) {
                                            int voterIndex = entry.key;
                                            int amount = entry.value;
                                            if (amount == 0) return const SizedBox.shrink();
                                            return Expanded(
                                              flex: amount,
                                              child: Container(
                                                color: getPlayerColor(voterIndex),
                                                alignment: Alignment.center,
                                                child: amount >= 10 ? Text("$amount", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)) : null,
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                Expanded(flex: maxPossibleTotal - total, child: const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.grey[200],
            child: Wrap(
              spacing: 10,
              runSpacing: 5,
              children: List.generate(players.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: getPlayerColor(index)),
                    const SizedBox(width: 4),
                    Text(players[index].name, style: const TextStyle(fontSize: 12)),
                  ],
                );
              }),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  onPressed: onHomePressed,
                  child: const Text(AppTexts.backToTitle, style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
