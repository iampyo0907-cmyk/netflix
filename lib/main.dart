import 'package:flutter/material.dart';

/// =======================
/// 데이터 모델
/// =======================
class Content {
  final String title;
  final String genre;
  final String imagePath;

  Content({
    required this.title,
    required this.genre,
    required this.imagePath,
  });
}

class Actor {
  final String name;
  final String description;

  Actor({
    required this.name,
    required this.description,
  });
}

/// =======================
/// 전역 데이터
/// =======================

final List<Content> bannerContents = [
  Content(title: '인터스텔라', genre: 'SF', imagePath: 'assets/images/a1.jpg'),
  Content(title: '군함도', genre: '액션', imagePath: 'assets/images/a2.jpg'),
  Content(title: '1987', genre: '드라마', imagePath: 'assets/images/a3.jpg'),
  Content(title: '라라랜드', genre: '로맨스', imagePath: 'assets/images/a4.jpg'),
];

final List<Content> allContents = [
  Content(title: '파묘', genre: '공포', imagePath: 'assets/images/p1.jpg'),
  Content(title: '1917', genre: '전쟁', imagePath: 'assets/images/p2.jpg'),
  Content(title: '범죄와의 전쟁', genre: '범죄', imagePath: 'assets/images/p3.jpg'),
  Content(title: '다크 나이트', genre: '액션', imagePath: 'assets/images/p4.jpg'),
  Content(title: '너의 이름은', genre: '애니메이션', imagePath: 'assets/images/p5.jpg'),
  Content(title: '백두산', genre: '재난', imagePath: 'assets/images/p6.jpg'),
];

final Map<String, List<Actor>> movieActors = {
  '인터스텔라': [
    Actor(name: '매튜 맥커너히', description: '인터스텔라에서 쿠퍼 역'),
    Actor(name: '앤 해서웨이', description: '인터스텔라에서 브랜드 박사 역'),
  ],
  '파묘': [
    Actor(name: '최민식', description: '파묘의 핵심 인물'),
    Actor(name: '김고은', description: '파묘의 주요 등장인물'),
  ],
};

final List<String> genres = [
  '전체',
  'SF',
  '드라마',
  '액션',
  '로맨스',
  '범죄',
  '공포',
  '전쟁',
  '애니메이션',
  '재난',
];

List<Content> myList = [];

void main() {
  runApp(const MyApp());
}

/// =======================
/// 앱 시작
/// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PhoneFrame(child: MainPage()),
    );
  }
}

/// =======================
/// 9:16 폰 프레임
/// =======================
class PhoneFrame extends StatelessWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: child,
        ),
      ),
    );
  }
}

/// =======================
/// 메인 페이지
/// =======================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: index == 0 ? const NetflixHome() : const MyListPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '내 목록'),
        ],
      ),
    );
  }
}

/// =======================
/// 배너 슬라이더
/// =======================
class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController controller = PageController();
  int current = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), autoSlide);
  }

  void autoSlide() {
    if (!controller.hasClients) return;
    current = (current + 1) % bannerContents.length;
    controller.animateToPage(
      current,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(milliseconds: 2200), autoSlide);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: PageView.builder(
        controller: controller,
        itemCount: bannerContents.length,
        itemBuilder: (context, i) {
          final content = bannerContents[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PhoneFrame(child: DetailPage(content: content)),
                ),
              );
            },
            child: Image.asset(content.imagePath, fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}

/// =======================
/// 홈 화면
/// =======================
class NetflixHome extends StatefulWidget {
  const NetflixHome({super.key});

  @override
  State<NetflixHome> createState() => _NetflixHomeState();
}

class _NetflixHomeState extends State<NetflixHome> {
  String selectedGenre = '전체';

  List<Content> get filteredContents {
    if (selectedGenre == '전체') return allContents;
    return allContents.where((c) => c.genre == selectedGenre).toList();
  }

  Widget genreSelector() {
    return SizedBox(
      height: 46,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: genres.length,
        itemBuilder: (context, i) {
          final genre = genres[i];
          final selected = genre == selectedGenre;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(genre),
              selected: selected,
              onSelected: (_) => setState(() => selectedGenre = genre),
              selectedColor: Colors.white,
              backgroundColor: Colors.grey[800],
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget contentCard(Content content) {
    final added = myList.contains(content);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PhoneFrame(child: DetailPage(content: content)),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 110,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: AssetImage(content.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  added ? myList.remove(content) : myList.add(content);
                });
              },
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black87,
                child: Icon(added ? Icons.check : Icons.add, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget section(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredContents.length,
            itemBuilder: (_, i) => contentCard(filteredContents[i]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const BannerSlider(),
        genreSelector(),
        section('추천 콘텐츠'),
        section('인기 콘텐츠'),
        const SizedBox(height: 30),
      ],
    );
  }
}

/// =======================
/// 영화 상세 페이지
/// =======================
class DetailPage extends StatefulWidget {
  final Content content;
  const DetailPage({super.key, required this.content});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final added = myList.contains(widget.content);
    final actors = movieActors[widget.content.title] ?? [];

    return Scaffold(
      body: ListView(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child:
                Image.asset(widget.content.imagePath, fit: BoxFit.cover),
              ),
              Positioned(
                top: 20,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.content.title,
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(widget.content.genre,
                style: const TextStyle(color: Colors.grey)),
          ),
          if (actors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('출연 배우',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...actors.map(
                        (actor) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhoneFrame(
                              child: ActorDetailPage(actor: actor),
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(actor.name,
                            style: const TextStyle(
                                color: Colors.blueAccent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  added
                      ? myList.remove(widget.content)
                      : myList.add(widget.content);
                });
              },
              child: Text(added ? '내 목록에서 제거' : '내 목록에 추가'),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 배우 상세 페이지
/// =======================
class ActorDetailPage extends StatelessWidget {
  final Actor actor;
  const ActorDetailPage({super.key, required this.actor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          IconButton(
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
          Text(actor.name,
              style:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(actor.description,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

/// =======================
/// 내 목록
/// =======================
class MyListPage extends StatelessWidget {
  const MyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (myList.isEmpty) {
      return const Center(
        child:
        Text('내 목록이 비어 있습니다', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final content = myList[i];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    PhoneFrame(child: DetailPage(content: content)),
              ),
            );
          },
          child: Image.asset(content.imagePath, fit: BoxFit.cover),
        );
      },
    );
  }
}
