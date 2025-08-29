import 'package:flutter/material.dart';
import '../services/game_service.dart';

// ================== LEADERBOARD ==================
class _LeaderboardCardWrapper extends StatelessWidget {
  final Widget child;
  final String backgroundAsset;

  const _LeaderboardCardWrapper({
    required this.child,
    required this.backgroundAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage("assets/$backgroundAsset"),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}

// ================== MACRO LEADERBOARD ==================
class MacroLeaderboardTable extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String currentUserName;

  const MacroLeaderboardTable({
    super.key,
    required this.entries,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final headFs = (w * 0.014).clamp(11.0, 18.0);
    final cellFs = (w * 0.012).clamp(10.0, 16.0);
    final cellPad = EdgeInsets.symmetric(
      horizontal: (w * 0.008).clamp(6.0, 12.0),
      vertical: (w * 0.006).clamp(4.0, 10.0),
    );

    return Card(
      color: const Color(0xF9DD9A00),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.5),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
          verticalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
        ),
        children: [
          //header row
          TableRow(children: [
            Padding(
              padding: cellPad,
              child: Text("RANK",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("PLAYER",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("SCORE",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("ACCURACY",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("GAMES",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
          ]),
          //data rows
          for (var e in entries)
            TableRow(
              decoration: e.playerName == currentUserName
                  ? const BoxDecoration(
                      color: Color(0xFFFFF59D)) //highlight current user
                  : null,
              children: [
                Padding(
                  padding: cellPad,
                  child: Text("${e.rank}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
                Padding(
                  padding: cellPad,
                  child: _PlayerCell(
                    playerName: e.playerName,
                  ),
                ),
                Padding(
                  padding: cellPad,
                  child: Text("${e.score}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
                Padding(
                  padding: cellPad,
                  child: Text("${e.accuracy.toStringAsFixed(1)}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
                Padding(
                  padding: cellPad,
                  child: Text("${e.gamesPlayed}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ================== GAME LEADERBOARD ==================
class GameLeaderboardTable extends StatelessWidget {
  final String gameTitle;
  final List<LeaderboardEntry> entries;
  final String currentUserName;

  const GameLeaderboardTable({
    super.key,
    required this.gameTitle,
    required this.entries,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final headFs = (w * 0.014).clamp(11.0, 18.0);
    final cellFs = (w * 0.012).clamp(10.0, 16.0);
    final cellPad = EdgeInsets.symmetric(
      horizontal: (w * 0.008).clamp(6.0, 12.0),
      vertical: (w * 0.006).clamp(4.0, 10.0),
    );

    return Card(
      color: const Color(0xF9DD9A00),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF5A3A00), width: 3),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
          verticalInside: BorderSide(color: Color(0xFF5A3A00), width: 1.2),
        ),
        children: [
          //header row
          TableRow(children: [
            Padding(
              padding: cellPad,
              child: Text("RANK",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("PLAYER",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("SCORE",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
            Padding(
              padding: cellPad,
              child: Text("ACCURACY",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: headFs)),
            ),
          ]),
          //data rows
          for (var e in entries)
            TableRow(
              decoration: e.playerName == currentUserName
                  ? const BoxDecoration(
                      color: Color(0xFFFFF59D)) //highlight current user
                  : null,
              children: [
                Padding(
                  padding: cellPad,
                  child: Text("${e.rank}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
                Padding(
                  padding: cellPad,
                  child: _PlayerCell(
                    playerName: e.playerName,
                  ),
                ),
                Padding(
                  padding: cellPad,
                  child: Text("${e.score}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
                Padding(
                  padding: cellPad,
                  child: Text("${e.accuracy.toStringAsFixed(1)}%",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: cellFs)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PlayerCell extends StatelessWidget {
  final String playerName;

  const _PlayerCell({
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cellFs = (w * 0.012).clamp(10.0, 16.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey[400],
          child: Text(
            playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            playerName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: cellFs),
          ),
        ),
      ],
    );
  }
}
