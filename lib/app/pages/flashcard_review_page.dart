import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardReviewPage extends StatefulWidget {
  final String subjectId;
  final String userId;

  const FlashcardReviewPage({
    super.key,
    required this.subjectId,
    required this.userId,
  });

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage> {
  List<Map<String, dynamic>> flashcards = [];
  int currentIndex = 0;
  bool showQuestion = true;

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  Future<void> _loadFlashcards() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('subjects')
        .doc(widget.subjectId)
        .collection('flashcards')
        .orderBy('timestamp', descending: false)
        .get();

    setState(() {
      flashcards = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void _flipCard() {
    setState(() => showQuestion = !showQuestion);
  }

  void _nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % flashcards.length;
      showQuestion = true;
    });
  }

  void _previousCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + flashcards.length) % flashcards.length;
      showQuestion = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Révision',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: const Center(child: Text("Aucune flashcard à réviser.")),
      );
    }

    final card = flashcards[currentIndex];
    final String front = card['front'] ?? '';
    final String back = card['back'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Révision',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _flipCard,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              height: 200,
              alignment: Alignment.center,
              child: Text(
                showQuestion ? front : back,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _previousCard,
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: _nextCard,
              ),
            ],
          )
        ],
      ),
    );
  }
}