import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'health_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final ValueNotifier<String> _sharedTextNotifier = ValueNotifier<String>('');

  @override
  void dispose() {
    _sharedTextNotifier.dispose();
    super.dispose();
  }

  void _switchToCardMakerWithText(String text) {
    _sharedTextNotifier.value = text;
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(sharedTextNotifier: _sharedTextNotifier),
      HealthScreen(
        onShareAsCard: (cardText) {
          _switchToCardMakerWithText(cardText);
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: const Color(0xFFD81B60),
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.image, size: 28),
              activeIcon: Icon(Icons.image, size: 30, color: Color(0xFFD81B60)),
              label: '카드 메이커',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.eco_outlined, size: 28),
              activeIcon: Icon(Icons.eco, size: 30, color: Color(0xFF2E7D32)),
              label: '매일 건강상식',
            ),
          ],
        ),
      ),
    );
  }
}
