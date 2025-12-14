import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile App UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const PhoneSizedWrapper(),
    );
  }
}

// 🔥 휴대폰 비율(9:16) 고정 래퍼
class PhoneSizedWrapper extends StatelessWidget {
  const PhoneSizedWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const MainPage(),
          ),
        ),
      ),
    );
  }
}

// 메인 페이지
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const NewPage(),
    const Center(
      child: Text(
        '프로필 화면',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
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
      backgroundColor: Colors.black,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fiber_new),
            label: "NEW",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "프로필",
          ),
        ],
      ),
    );
  }
}

// 🔹 홈 화면
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final int cardsPerLine = 12;
    final double cardWidth = 80;
    final double cardHeight = 150;
    final double sidePadding = 16;
    final double cardSpacing = 8;

    Widget buildCardLine(int lineIndex) {
      return SizedBox(
        height: cardHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          itemCount: cardsPerLine,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : cardSpacing / 2,
                right: index == cardsPerLine - 1 ? 0 : cardSpacing / 2,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                          cardLabel: 'L${lineIndex + 1}-${index + 1}'),
                    ),
                  );
                },
                child: Container(
                  width: cardWidth,
                  decoration: BoxDecoration(
                    gradient: lineIndex == 0
                        ? const LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)
                        : const LinearGradient(
                        colors: [Colors.greenAccent, Colors.tealAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'L${lineIndex + 1}-${index + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildCardLine(0),
        const SizedBox(height: 16),
        buildCardLine(1),
        const SizedBox(height: 16),
      ],
    );
  }
}

// 🔹 NEW 화면
class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black.withOpacity(0.4),
                    child: Text(
                      '사각형 ${index + 1}',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 🔹 상세 화면: AppBar도 제거한 버전
class DetailPage extends StatelessWidget {
  final String cardLabel;
  const DetailPage({super.key, required this.cardLabel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Column(
                children: [
                  // 🔙 직접 만든 뒤로가기 버튼
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 40, left: 16, bottom: 8),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                  ),

                  // 상단 16:9 박스
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '상단 16:9 상자',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Center(
                      child: Text(
                        '$cardLabel ',
                        style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
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
