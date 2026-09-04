import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/wisdom_data.dart';
import '../services/theme_service.dart';
import '../widgets/share_preview_dialog.dart';

class WisdomScreen extends StatefulWidget {
  final Function(String cardText, {String? bgPath})? onShareAsCard;

  const WisdomScreen({super.key, this.onShareAsCard});

  @override
  State<WisdomScreen> createState() => _WisdomScreenState();
}

class _WisdomScreenState extends State<WisdomScreen> {
  String _selectedCategory = '전체';
  final Set<String> _likedIds = {};

  final List<String> _categories = [
    '전체',
    '❤️ 찜한 명언',
    '🌅 아침·희망',
    '🌿 삶의 지혜',
    '💖 위로·응원',
    '🤝 인연·우정',
    '🧘 마음비움·평화',
    '📜 명사 명언',
  ];

  String _getSuggestedBgPathForItem(WisdomItem item) {
    final cat = item.category;
    if (cat.contains('아침') || cat.contains('희망')) {
      return 'assets/images/bg1.png'; // 화사한 일출과 햇살
    } else if (cat.contains('지혜') || cat.contains('명사')) {
      return 'assets/images/bg_tea.png'; // 여유로운 따뜻한 차 한잔
    } else if (cat.contains('위로') || cat.contains('응원')) {
      return 'assets/images/bg_garden_path.jpg'; // 꽃길 따라 봄 산책
    } else if (cat.contains('평화') || cat.contains('마음비움')) {
      return 'assets/images/bg_bamboo.png'; // 푸르른 대나무 숲
    } else if (cat.contains('인연') || cat.contains('우정')) {
      return 'assets/images/bg_rose_1786333119291.png'; // 향기로운 장미 부케
    }
    return 'assets/images/bg_tea.png';
  }

  @override
  void initState() {
    super.initState();
    _loadLikedIds();
  }

  Future<void> _loadLikedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('liked_wisdom_ids');
      if (list != null) {
        setState(() {
          _likedIds.addAll(list);
        });
      }
    } catch (e) {
      debugPrint('Error loading liked wisdoms: $e');
    }
  }

  Future<void> _saveLikedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('liked_wisdom_ids', _likedIds.toList());
    } catch (e) {
      debugPrint('Error saving liked wisdoms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredList = _selectedCategory == '전체'
        ? wisdomList
        : _selectedCategory == '❤️ 찜한 명언'
            ? wisdomList.where((item) => _likedIds.contains(item.id)).toList()
            : wisdomList.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141724) : const Color(0xFFFAF7F2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                  : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_rounded, color: Color(0xFFFFD700), size: 24),
            const SizedBox(width: 8),
            Text(
              '좋은글 & 명언',
              style: GoogleFonts.jua(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _selectedCategory == '❤️ 찜한 명언'
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _selectedCategory == '❤️ 찜한 명언'
                  ? const Color(0xFFFF4081)
                  : const Color(0xFFFFD700),
              size: 24,
            ),
            tooltip: _selectedCategory == '❤️ 찜한 명언' ? '전체 명언 보기' : '내가 찜한 명언 모아보기',
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (_selectedCategory == '❤️ 찜한 명언') {
                  _selectedCategory = '전체';
                } else {
                  _selectedCategory = '❤️ 찜한 명언';
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny : Icons.nightlight_round,
              color: isDark ? const Color(0xFFFFD700) : Colors.white,
            ),
            tooltip: isDark ? '라이트 모드로 전환' : '다크 모드로 전환',
            onPressed: () {
              HapticFeedback.lightImpact();
              ThemeService().toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF1E2234) : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFC5CCE0) : const Color(0xFF5D4037)),
                        ),
                      ),
                      selectedColor: isDark ? const Color(0xFF6B21A8) : const Color(0xFFD35400),
                      backgroundColor: isDark ? const Color(0xFF272D45) : const Color(0xFFFFF1E6),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark ? Colors.white12 : const Color(0xFFFFCCBC)),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 2. Wisdom Cards List or Empty State
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF2C1938) : const Color(0xFFFFEBEE),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 48,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '아직 찜한 좋은글이 없습니다',
                            style: GoogleFonts.jua(
                              fontSize: 20,
                              color: isDark ? Colors.white : const Color(0xFF2C1810),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '마음에 드는 명언 카드의 하트(❤️)를 누르면\n나만의 찜 목록에 쏙 모아집니다 ✨',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.5,
                              color: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedCategory = '전체');
                            },
                            icon: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                            label: const Text(
                              '전체 명언 보러가기',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD35400),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isLiked = _likedIds.contains(item.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2234) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white12 : const Color(0x1F8D6E63),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : const Color(0x0F8D6E63),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header: Category Badge & Like Button
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2B324D) : const Color(0xFFFFF0E6),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark ? const Color(0x44FFD700) : const Color(0xFFFFCCBC),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(item.emoji, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 5),
                                        Text(
                                          item.category,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                      color: isLiked ? const Color(0xFFE91E63) : Colors.grey,
                                      size: 22,
                                    ),
                                    tooltip: isLiked ? '좋아요 취소' : '마음 담기',
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        if (isLiked) {
                                          _likedIds.remove(item.id);
                                        } else {
                                          _likedIds.add(item.id);
                                        }
                                      });
                                      _saveLikedIds();
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Title
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              child: Text(
                                item.title,
                                style: GoogleFonts.jua(
                                  fontSize: 20,
                                  color: isDark ? const Color(0xFFFFD700) : const Color(0xFF2C1810),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),

                            // Content Box (Papyrus Style Frame)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141724) : const Color(0xFFFFFDF8),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? Colors.white10 : const Color(0x1F8D6E63),
                                    width: 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      item.content,
                                      style: TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? const Color(0xFFE0E6ED) : const Color(0xFF3E2723),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '- ${item.author} -',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? const Color(0xFFA0AEC0) : const Color(0xFF8D6E63),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Tags Row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: item.tags.map((tag) {
                                  return Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF718096) : const Color(0xFFA1887F),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            // Action Buttons (카드로 꾸미기 & 카카오톡 공유)
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                              child: Row(
                                children: [
                                  // 1. 카드로 꾸미기
                                  if (widget.onShareAsCard != null)
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 44,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(22),
                                          color: isDark ? const Color(0xFF2C2220) : const Color(0xFFFFEDE2),
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF5D4037) : const Color(0xFFFFCCBC),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            final bg = _getSuggestedBgPathForItem(item);
                                            widget.onShareAsCard!(item.content, bgPath: bg);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.brush_rounded,
                                                    size: 16,
                                                    color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '카드로 꾸미기',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13.5,
                                                      color: isDark ? const Color(0xFFFFAB91) : const Color(0xFFBF360C),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (widget.onShareAsCard != null) const SizedBox(width: 10),

                                  // 2. 카카오톡 공유
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 44,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        color: const Color(0xFFFEE500),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x33FEE500),
                                            blurRadius: 6,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          SharePreviewDialog.show(
                                            context: context,
                                            type: SharePreviewType.wisdom,
                                            title: item.title,
                                            content: item.content,
                                            author: item.author,
                                            emoji: item.emoji,
                                            fullShareText: item.shareText,
                                            onCustomizeCard: widget.onShareAsCard != null
                                                ? () {
                                                    final bg = _getSuggestedBgPathForItem(item);
                                                    widget.onShareAsCard!(item.content, bgPath: bg);
                                                  }
                                                : null,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 6),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.share_rounded, color: Colors.black87, size: 17),
                                                SizedBox(width: 5),
                                                Text(
                                                  '카톡 공유',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.5,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
