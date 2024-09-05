import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twozerofoureight/tiles.dart';

const Map<int, Color> gametilecolor = {
  2: Color.fromARGB(255, 252, 250, 222),
  4: Color.fromARGB(255, 234, 226, 115),
  8: Color.fromARGB(255, 241, 179, 9),
  16: Color.fromARGB(255, 240, 139, 50),
  32: Color.fromARGB(255, 195, 91, 0),
  64: Color.fromRGBO(244, 0, 0, 1),
  128: Color.fromARGB(255, 157, 0, 0),
  256: Color.fromARGB(255, 94, 1, 1),
  512: Color.fromARGB(255, 38, 4, 101),
  1024: Color.fromARGB(255, 20, 4, 50),
  2048: Color.fromARGB(255, 9, 175, 212),
};

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController control;
  List<List<Tiles>> grid = List.generate(4, (y) => List.generate(4, (x) => Tiles(x, y, 0)));
  List<Tiles> toAdd = [];
  Iterable<Tiles> get flattened => grid.expand((e) => e);
  Iterable<List<Tiles>> get cols => List.generate(4, (x) => List.generate(4, (y) => grid[y][x]));

  @override
  void initState() {
    super.initState();
    control = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    control.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        toAdd.forEach((element) {
          grid[element.y][element.x].val = element.val;
        });
        flattened.forEach((element) {
          element.resetAnimations();
        });
        toAdd.clear();
        addNewTile(); // Add a new tile after the animation completes
      }
    });
    grid[0][0].val = 2;
    grid[0][1].val = 2;
    grid[1][1].val = 2048;
    flattened.forEach((element) => element.resetAnimations());
    addNewTile(); // Initialize with a new tile
  }

  void addNewTile() {
    List<Tiles> empty = flattened.where((e) => e.val == 0).toList();
    if (empty.isNotEmpty) {
      empty.shuffle();
      toAdd.add(Tiles(empty.first.x, empty.first.y, 2)..appear(control));
    }
  }

  @override
  void dispose() {
    control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = 430;
    double tilesize = 400 / 4;
    double spacing = 7; // Spacing between tiles
    double offset = (size - (4 * tilesize) - (3 * spacing)) / 2; // Calculate offset to center the tiles

    List<Widget> stackItems = [];

    stackItems.addAll([flattened, toAdd].expand((e) => e).map((e) => Positioned(
      left: offset + e.animationX.value * (tilesize + spacing),
      top: offset + e.animationY.value * (tilesize + spacing),
      width: tilesize,
      height: tilesize,
      child: Container(
        width: tilesize * e.scale.value,
        height: tilesize * e.scale.value,
        decoration: BoxDecoration(
          color: Colors.black, // Color based on tile value
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    )));

    stackItems.addAll(flattened.map((e) => AnimatedBuilder(
      animation: control,
      builder: (context, child) => e.animatedvalue.value == 0
          ? SizedBox()
          : Positioned(
              left: offset + e.x * (tilesize + spacing),
              top: offset + e.y * (tilesize + spacing),
              width: tilesize,
              height: tilesize,
              child: Container(
                width: tilesize,
                height: tilesize,
                decoration: BoxDecoration(
                  color: gametilecolor[e.animatedvalue.value], // Color based on tile value
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "${e.animatedvalue.value}",
                    style: GoogleFonts.ubuntu(
                      fontSize: e.animatedvalue.value <= 1024 ? 50 : 40,
                      fontWeight: FontWeight.bold,
                      color: e.animatedvalue.value <= 8 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
    )));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dy > 150 && canswipeup()) {
              doSwipe(SwipeUp);  // Swap with SwipeDown
            } else if (details.velocity.pixelsPerSecond.dy < -150 && canswipedown()) {
              doSwipe(SwipeDown);  // Swap with SwipeUp
            }
          },
          onHorizontalDragEnd: (details) {
            if (details.velocity.pixelsPerSecond.dx > 150 && canswipeleft()) {
              doSwipe(SwipeLeft);  // Swap with SwipeRight
            } else if (details.velocity.pixelsPerSecond.dx < -150 && canswiperight()) {
              doSwipe(SwipeRight);  // Swap with SwipeLeft
            }
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 46, 46).withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: RepaintBoundary(
              child: Stack(
                children: stackItems,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void doSwipe(void Function() swipeFn) {
    setState(() {
      swipeFn();
      flattened.forEach((element) {
        element.resetAnimations();
      });
      control.forward(from: 0);
    });
  }

  bool canswipeleft() => grid.any(canSwipe);
  bool canswiperight() => grid.map((e) => e.reversed.toList()).any(canSwipe);
  bool canswipeup() => cols.any(canSwipe);
  bool canswipedown() => cols.map((e) => e.reversed.toList()).any(canSwipe);

  bool canSwipe(List<Tiles> tile) {
    for (int i = 0; i < tile.length; i++) {
      if (tile[i].val == 0) {
        if (tile.skip(i + 1).any((e) => e.val != 0)) {
          return true;
        }
      } else {
        Tiles nextNonZero = tile.skip(i + 1).firstWhere(
          (e) => e.val != 0,
          orElse: () => Tiles(-1, -1, 0),
        );
        if (nextNonZero.val != 0 && nextNonZero.val == tile[i].val) {
          return true;
        }
      }
    }
    return false;
  }

  void SwipeLeft() {
    grid.forEach(mergeTiles);
    control.forward(from: 0);
  }

  void SwipeRight() {
    grid.map((e) => e.reversed.toList()).forEach(mergeTiles);
    control.forward(from: 0);
  }

  void SwipeUp() {
    cols.forEach(mergeTiles);
    control.forward(from: 0);
  }

  void SwipeDown() {
    cols.map((e) => e.reversed.toList()).forEach(mergeTiles);
    control.forward(from: 0);
  }

  void mergeTiles(List<Tiles> tile) {
    for (int i = 0; i < tile.length; i++) {
      Iterable<Tiles> toCheck = tile.skip(i).skipWhile((value) => value.val == 0);
      if (toCheck.isNotEmpty) {
        Tiles t = toCheck.first;
        Tiles merge = toCheck.skip(1).firstWhere(
          (t) => t.val != 0,
          orElse: () => Tiles(-1, -1, 0),
        );

        if (merge.val != 0 && merge.val != t.val) {
          merge = Tiles(-1, -1, 0);
        }
        if (tile[i] != t || merge.val != 0) {
          int resultValue = t.val;
          t.moveTo(control, tile[i].x, tile[i].y);
          if (merge.val != 0) {
            resultValue += merge.val;
            merge.moveTo(control, tile[i].x, tile[i].y);
            merge.bounce(control);
            merge.changenumber(control, resultValue);
            merge.val = 0;
            t.changenumber(control, 0);
          }
          t.val = 0;
          tile[i].val = resultValue;
        }
      }
    }
  }
}
