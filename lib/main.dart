import 'package:flutter/material.dart';
import 'dart:math';


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

// 추가: 리뷰 모델 및 전역 리뷰 저장소
class Review {
  final String author;
  final String content;
  final int rating; // 1..5
  final DateTime createdAt;

  Review({
    required this.author,
    required this.content,
    required this.rating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

// 영화 타이틀(key) -> 리뷰 목록
final Map<String, List<Review>> reviewsMap = {};

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

/// 전역 다크모드 상태 관리
ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);

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
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, dark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const PhoneFrame(child: MainPage()),
        );
      },
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
      child: Stack(
        children: [
          PageView.builder(
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
          // 설정 아이콘: 우측 상단에 항상 표시되고 탭하면 설정 상세 페이지로 이동
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhoneFrame(child: SettingsPage()),
                  ),
                );
              },
            ),
          ),
        ],
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
  String searchQuery = '';

  // 장르 필터와 검색어를 함께 적용한 결과 반환 (대소문자 구분 없이 제목 부분 일치)
  List<Content> get filteredContents {
    final byGenre = (selectedGenre == '전체')
        ? allContents
        : allContents.where((c) => c.genre == selectedGenre).toList();

    if (searchQuery.trim().isEmpty) return byGenre;
    final q = searchQuery.trim().toLowerCase();
    return byGenre.where((c) => c.title.toLowerCase().contains(q)).toList();
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
    final items = List<Content>.from(filteredContents);
    items.shuffle(Random());

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
            itemCount: items.length,
            itemBuilder: (_, i) => contentCard(items[i]),
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
        // 검색바: 배너 아래, 장르 선택 위에 위치
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: '콘텐츠 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => setState(() => searchQuery = ''),
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.12),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => setState(() => searchQuery = v),
          ),
        ),
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
  // 추가: 리뷰 입력 컨트롤러 및 평점 상태
  final TextEditingController _reviewAuthorController = TextEditingController();
  final TextEditingController _reviewContentController = TextEditingController();
  int _reviewRating = 5;

  @override
  void dispose() {
    _reviewAuthorController.dispose();
    _reviewContentController.dispose();
    super.dispose();
  }

  double _averageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<int>(0, (p, e) => p + e.rating);
    return sum / reviews.length;
  }

  void _submitReview() {
    final author = _reviewAuthorController.text.trim();
    final content = _reviewContentController.text.trim();
    if (author.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('작성자와 내용을 입력해주세요')),
      );
      return;
    }

    final review = Review(author: author, content: content, rating: _reviewRating);
    final title = widget.content.title;
    reviewsMap.putIfAbsent(title, () => []).add(review);

    // 입력 초기화 및 UI 갱신
    setState(() {
      _reviewAuthorController.clear();
      _reviewContentController.clear();
      _reviewRating = 5;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('리뷰가 추가되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final added = myList.contains(widget.content);
    final actors = movieActors[widget.content.title] ?? [];
    final reviews = reviewsMap[widget.content.title] ?? [];
    final description =
        movieDescriptions[widget.content.title] ?? '간단한 설명이 없습니다.';

    return Scaffold(
      body: ListView(
        children: [
          Stack(
            children: [
              // 포스터를 화면 폭에 딱 맞게 표시: 고정 높이 박스 + cover로 채움
              SizedBox(
                width: double.infinity,
                // PhoneFrame 안에서 적절한 높이 비율 사용
                height: MediaQuery.of(context).size.height * 0.45,
                child: Image.asset(
                  widget.content.imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
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
                            style: const TextStyle(color: Colors.blueAccent)),
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
                  added ? myList.remove(widget.content) : myList.add(widget.content);
                });
              },
              child: Text(added ? '내 목록에서 제거' : '내 목록에 추가'),
            ),
          ),

          // 영화 간단 설명: 리뷰 섹션 바로 위에 표시
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              description,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          // --------------------
          // 리뷰 섹션 시작
          // --------------------
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text('리뷰',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                if (reviews.isNotEmpty)
                  Text(
                    '${_averageRating(reviews).toStringAsFixed(1)} ★ (${reviews.length})',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
          ),
          // 리뷰 목록
          if (reviews.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: reviews.reversed.map((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('${r.rating} ★', style: const TextStyle(color: Colors.orange)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(r.content),
                        const SizedBox(height: 6),
                        Text(
                          r.createdAt.toLocal().toString().split('.').first,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('아직 등록된 리뷰가 없습니다', style: TextStyle(color: Colors.grey)),
            ),

          // 리뷰 입력 폼
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('리뷰 작성', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewAuthorController,
                  decoration: const InputDecoration(
                    labelText: '작성자',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('평점:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _reviewRating,
                      items: List.generate(5, (i) => i + 1)
                          .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _reviewRating = v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewContentController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '리뷰 내용',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _submitReview,
                  child: const Text('리뷰 등록'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// =======================
/// 배우 상세 페이지 (출연 영화 적용)
/// =======================
class ActorDetailPage extends StatelessWidget {
  final Actor actor;
  const ActorDetailPage({super.key, required this.actor});

  List<Content> get actorMovies {
    final List<Content> results = [];
    // 모든 콘텐츠를 합쳐서 검색 (banner + all)
    final combined = [...allContents, ...bannerContents];

    movieActors.forEach((movieTitle, actors) {
      for (final a in actors) {
        if (a.name == actor.name) {
          try {
            final content = combined.firstWhere((c) => c.title == movieTitle);
            results.add(content);
          } catch (_) {
            // 해당 타이틀을 찾지 못하면 무시 (안전 처리)
          }
        }
      }
    });

    return results;
  }

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
          Text(actor.description, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          if (actorMovies.isNotEmpty) ...[
            const Text('출연 작품',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actorMovies.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (_, i) {
                final content = actorMovies[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhoneFrame(
                          child: DetailPage(content: content),
                        ),
                      ),
                    );
                  },
                  child: Image.asset(content.imagePath, fit: BoxFit.cover),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// =======================
/// 내 목록
/// =======================
class MyListPage extends StatefulWidget {
  const MyListPage({super.key});

  @override
  State<MyListPage> createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  double _avgRatingFor(String title) {
    final reviews = reviewsMap[title] ?? [];
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<int>(0, (p, e) => p + e.rating);
    return sum / reviews.length;
  }

  int _countFor(String title) => (reviewsMap[title] ?? []).length;

  // myList의 장르별 집계
  Map<String, int> _genreCounts() {
    final Map<String, int> counts = {};
    for (final c in myList) {
      counts[c.genre] = (counts[c.genre] ?? 0) + 1;
    }
    return counts;
  }

  Widget _genreBarChart() {
    final counts = _genreCounts();
    if (counts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('찜한 작품이 없습니다. 장르 통계를 볼 수 없습니다.',
            style: TextStyle(color: Colors.grey)),
      );
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCount = entries.first.value.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text('찜한 장르 통계', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Column(
          children: entries.map((e) {
            final fraction = (maxCount == 0) ? 0.0 : (e.value / maxCount);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(width: 72, child: Text(e.key, style: const TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${e.value}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (myList.isEmpty) {
      return const Center(
        child: Text('내 목록이 비어 있습니다', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 장르 통계 바 차트
        _genreBarChart(),

        // 썸네일 그리드
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: myList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2 / 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final content = myList[i];
            final avg = _avgRatingFor(content.title);
            final cnt = _countFor(content.title);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PhoneFrame(child: DetailPage(content: content)),
                  ),
                ).then((_) => setState(() {})); // 상세에서 변경된 리뷰/찜 반영
              },
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(content.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                  // 좌하단: 평균 평점 및 리뷰 수 오버레이
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            avg > 0 ? avg.toStringAsFixed(1) : '-',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          if (cnt > 0)
                            Text('($cnt)', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 18),

        // 리뷰 기록 섹션: myList에 있는 작품들의 리뷰들을 모아 역순(최근순)으로 표시
        const Text('리뷰 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Builder(builder: (context) {
          final List<MapEntry<String, Review>> records = [];
          for (final content in myList) {
            final reviews = reviewsMap[content.title] ?? [];
            for (final r in reviews) {
              records.add(MapEntry(content.title, r));
            }
          }
          records.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));

          if (records.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('내 목록에 해당하는 리뷰 기록이 없습니다', style: TextStyle(color: Colors.grey)),
            );
          }

          return Column(
            children: records.map((entry) {
              final title = entry.key;
              final r = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text('${r.rating} ★', style: const TextStyle(color: Colors.orange)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(r.content),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.author, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(r.createdAt.toLocal().toString().split('.').first, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

/// =======================
/// 설정 상세 페이지 (간단한 예시)
/// =======================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 상단: 뒤로가기 + 타이틀
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text('설정',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            // 다크모드: 전역 상태와 연동
            ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, dark, _) {
                return SwitchListTile(
                  title: const Text('다크 모드'),
                  value: dark,
                  onChanged: (v) => isDarkMode.value = v,
                );
              },
            ),
            SwitchListTile(
              title: const Text('알림 받기'),
              value: notifications,
              onChanged: (v) => setState(() => notifications = v),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('계정 관리'),
              subtitle: const Text('로그인 정보 및 프로필 설정'),
              onTap: () {
                // 필요시 상세 화면으로 연결 가능
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('앱 정보'),
              subtitle: const Text('버전 및 라이선스'),
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text('고급 설정',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('데이터 관리'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('로그아웃'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

final Map<String, String> movieDescriptions = {
  '인터스텔라':
  '우주 탐사를 통해 인류의 생존을 모색하는 과학적 상상력과 가족애를 결합한 SF 서사.',
  '군함도':
  '역사적 배경을 바탕으로 한 액션 드라마로, 극한 상황 속 인간의 선택을 그린 작품.',
  '1987':
  '실화를 모티프로 한 정치 드라마로, 민주화를 향한 시민의 목소리와 시대의 갈등을 그립니다.',
  '라라랜드':
  '꿈과 사랑 사이에서 갈등하는 두 예술가의 로맨틱 뮤지컬 영화.',
  '파묘':
  '소름 끼치는 분위기와 미스터리를 앞세운 공포 스릴러.',
  '1917':
  '제1차 세계대전 전장을 배경으로 한 긴장감 넘치는 전쟁 드라마.',
  '범죄와의 전쟁':
  '범죄와 권력의 유착을 사실적으로 그려낸 범죄 영화.',
  '다크 나이트':
  '히어로 영화의 틀을 넘어선 심리적 갈등과 도덕적 딜레마를 탐구하는 액션물.',
  '너의 이름은':
  '운명적으로 얽힌 두 인물의 감성적인 이야기와 환상적 요소를 결합한 애니메이션.',
  '백두산':
  '대규모 재난 상황에서 펼쳐지는 긴박한 액션과 구조 드라마.',
};
