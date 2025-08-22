import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

const int boardSize = 3;
const String playerOMark = "O";
const String playerXMark = "X";
const Color oColor = Colors.blue;
const Color xColor = Colors.redAccent;
const double lineStrokeWidth = 3;
const double markStrokeWidth = 6;
int? lastRow;
int? lastCol;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: Scaffold(body: GameBoard())),
    );
  }
}

class GameBoard extends StatefulWidget {
  @override
  _GameBoardState createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  List<List<String>> board = List.generate(
    boardSize,
    (_) => List.generate(boardSize, (_) => ""),
  );

  bool playerTurn = false;
  String winner = "";

  void _tableTap(TapDownDetails details, double tableWidth) {
    double cellSize = tableWidth / boardSize;
    int col = (details.localPosition.dx / cellSize).floor();
    int row = (details.localPosition.dy / cellSize).floor();

    if (row >= 0 &&
        row < boardSize &&
        col >= 0 &&
        col < boardSize &&
        board[row][col] == '') {
      setState(() {
        board[row][col] = playerTurn ? playerXMark : playerOMark;

        lastRow = row;
        lastCol = col;

        if (!playerTurn) {
          _oController.reset();
          _oController.forward();
        } else {
          _xController.reset();
          _xController.forward();
        }

        playerTurn = !playerTurn;
      });
    }
  }

  String playerText() {
    return playerTurn ? playerXMark : playerOMark;
  }

  String showWinner(List<List<String>> b) {
    int i = 0;
    while (i < boardSize) {
      if (b[i][0] != "") {
        int j = 1;
        bool win = true;
        while (j < boardSize) {
          if (b[i][j] != b[i][0]) {
            win = false;
            break;
          }
          j++;
        }
        if (win) return b[i][0];
      }
      i++;
    }

    int col = 0;
    while (col < boardSize) {
      if (b[0][col] != "") {
        int row = 1;
        bool win = true;
        while (row < boardSize) {
          if (b[row][col] != b[0][col]) {
            win = false;
            break;
          }
          row++;
        }
        if (win) return b[0][col];
      }
      col++;
    }

    if (b[0][0] != "") {
      int k = 1;
      bool win = true;
      while (k < boardSize) {
        if (b[k][k] != b[0][0]) {
          win = false;
          break;
        }
        k++;
      }
      if (win) return b[0][0];
    }

    if (b[0][boardSize - 1] != "") {
      int k = 1;
      bool win = true;
      while (k < boardSize) {
        if (b[k][boardSize - 1 - k] != b[0][boardSize - 1]) {
          win = false;
          break;
        }
        k++;
      }
      if (win) return b[0][boardSize - 1];
    }

    int r = 0;
    while (r < boardSize) {
      int c = 0;
      while (c < boardSize) {
        if (b[r][c] == "") {
          return "";
        }
        c++;
      }
      r++;
    }

    return "Tie";
  }

  void clearBoard() {
    setState(() {
      for (int i = 0; i < boardSize; i++) {
        for (int j = 0; j < boardSize; j++) {
          board[i][j] = "";
        }
      }
      winner = "";
      playerTurn = false;
    });
  }

  late AnimationController _oController;
  late AnimationController _xController;
  late Animation<double> oSizeAnimation;
  late Animation<double> xSizeAnimation;

  @override
  void initState() {
    super.initState();

    _oController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    oSizeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.6,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.2,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_oController);

    _xController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    xSizeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.2,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0.6,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_xController);
  }

  @override
  Widget build(BuildContext context) {
    double tableSize = MediaQuery.of(context).size.width;
    winner = showWinner(board);
    return MaterialApp(
      title: 'Supa basic widget',
      home: Scaffold(
        body: GestureDetector(
          onTapDown: (details) {
            if (winner == "") {
              _tableTap(details, tableSize);
            }
          },
          child: Column(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([oSizeAnimation, xSizeAnimation]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(tableSize, tableSize),
                    painter: OxTablePainter(
                      board,
                      oSizeAnimation.value,
                      xSizeAnimation.value,
                    ),
                  );
                },
              ),
              SizedBox(height: tableSize / 10),
              Text("Turn : ${playerText()}", style: TextStyle(fontSize: 28)),
              SizedBox(height: tableSize / 10),
              if (winner != "")
                Text("Winner : $winner", style: TextStyle(fontSize: 28)),
              SizedBox(height: tableSize / 10),
              if (winner != "")
                ElevatedButton(
                  onPressed: clearBoard,
                  child: Text(
                    'Clear board',
                    style: TextStyle(fontSize: 28, color: Colors.black),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OxTablePainter extends CustomPainter {
  final List<List<String>> board;
  final double radius;
  final double gap;
  OxTablePainter(this.board, this.radius, this.gap);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = lineStrokeWidth;

    double cellWidth = size.width / boardSize;
    double cellHeight = size.height / boardSize;

    for (int i = 0; i <= boardSize; i++) {
      canvas.drawLine(
        Offset(0, cellHeight * i),
        Offset(size.width, cellHeight * i),
        paint,
      );
      canvas.drawLine(
        Offset(cellWidth * i, 0),
        Offset(cellWidth * i, size.height),
        paint,
      );
    }

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        double cellSize = size.width / boardSize;
        if (row == lastRow && col == lastCol) {
          // lastest
          if (board[row][col] == playerOMark) {
            final oPaint = Paint()
              ..color = oColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = markStrokeWidth;
            final center = Offset(
              col * cellSize + cellSize / 2,
              row * cellSize + cellSize / 2,
            );

            canvas.drawCircle(center, radius * (cellSize / 3), oPaint);
          } else if (board[row][col] == playerXMark) {
            final xPaint = Paint()
              ..color = xColor
              ..strokeCap = StrokeCap.round
              ..strokeWidth = markStrokeWidth;
            final left = col * cellSize;
            final top = row * cellSize;
            final right = left + cellSize;
            final bottom = top + cellSize;
            final cellspace = cellSize / 5;
            canvas.drawLine(
              Offset(left + (gap * cellspace), top + (gap * cellspace)),
              Offset(right - (gap * cellspace), bottom - (gap * cellspace)),
              xPaint,
            );
            canvas.drawLine(
              Offset(right - (gap * cellspace), top + (gap * cellspace)),
              Offset(left + (gap * cellspace), bottom - (gap * cellspace)),
              xPaint,
            );
          }
        } else {
          // not latest
          if (board[row][col] == playerOMark) {
            final oPaint = Paint()
              ..color = oColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = markStrokeWidth;
            final center = Offset(
              col * cellSize + cellSize / 2,
              row * cellSize + cellSize / 2,
            );
            canvas.drawCircle(center, cellSize / 3, oPaint);
          } else if (board[row][col] == playerXMark) {
            final xPaint = Paint()
              ..color = xColor
              ..strokeCap = StrokeCap.round
              ..strokeWidth = markStrokeWidth;
            final left = col * cellSize;
            final top = row * cellSize;
            final right = left + cellSize;
            final bottom = top + cellSize;
            final cellspace = cellSize / 5;
            canvas.drawLine(
              Offset(left + cellspace, top + cellspace),
              Offset(right - cellspace, bottom - cellspace),
              xPaint,
            );
            canvas.drawLine(
              Offset(right - cellspace, top + cellspace),
              Offset(left + cellspace, bottom - cellspace),
              xPaint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant OxTablePainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.gap != gap;
  }
}
