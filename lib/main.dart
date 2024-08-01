import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const BottomNavigationBarExampleApp());

class BottomNavigationBarExampleApp extends StatelessWidget {
  const BottomNavigationBarExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavigationBarExample(),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Индекс 0: Главная',
      style: optionStyle,
    ),
    Text(
      'Индекс 1: Бизнес',
      style: optionStyle,
    ),
    Text(
      'Индекс 2: Школа',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пример BottomNavigationBar'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.abc),
        onPressed: () {},
        mini: false,
      ),
      floatingActionButtonLocation:
          CustomCenterDockedFloatingActionButtonLocation(),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.only(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BottomAppBar(
              shape: CustomCircularNotchedRectangle(
                notchOffset: const Offset(-20, 0), // Вырез по центру
              ),
              notchMargin: 10, // Настройка отступа между FAB и вырезом
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  TextButton(
                    child: const Text(
                      'Бизнес',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      // Действие при нажатии кнопки
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thumb_up), // Иконка
                        SizedBox(height: 2), // Отступ между иконкой и текстом
                        Text('Нравится'), // Текст
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCircularNotchedRectangle extends NotchedShape {
  CustomCircularNotchedRectangle({
    this.notchOffset = const Offset(0, 0),
  });
  final Offset notchOffset;

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);
    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.width / 2;
    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curve from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: goo.gl/Ufzrqn

    const double s1 = 0;
    const double s2 = 0;

    final double r = notchRadius - 0.1;
    final double a = -1 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset?> p = List<Offset?>.filled(6, null);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2]!.dx, p[2]!.dy);
    p[4] = Offset(-1.0 * p[1]!.dx, p[1]!.dy);
    p[5] = Offset(-1.0 * p[0]!.dx, p[0]!.dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] = p[i]! + guest.center + notchOffset;
    }

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(p[0]!.dx, p[0]!.dy)
      ..quadraticBezierTo(p[1]!.dx, p[1]!.dy, p[2]!.dx, p[2]!.dy)
      ..arcToPoint(
        p[3]!,
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..quadraticBezierTo(p[4]!.dx, p[4]!.dy, p[5]!.dx, p[5]!.dy)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

class CustomCenterDockedFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabHalfWidth =
        scaffoldGeometry.floatingActionButtonSize.width / 2.0;
    final double contentBottom = scaffoldGeometry.contentBottom;

    // Опустить FAB ниже, увеличив отступ
    const double bottomMargin = -6; // Настройка вертикального отступа

    return Offset(
      (scaffoldGeometry.scaffoldSize.width - fabHalfWidth) / 2.0,
      contentBottom - fabHalfWidth - bottomMargin,
    );
  }
}
