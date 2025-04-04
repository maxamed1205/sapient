import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sapient/services/firestore_services.dart';
import 'add_flashcard_page.dart';
import 'flashcard_review_page.dart';
import 'flashcard_view_page.dart';

class FlashcardPage extends StatefulWidget {
  final String subjectId;
  final String userId;

  const FlashcardPage({
    super.key,
    required this.subjectId,
    required this.userId,
  });

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7FF),
      appBar: AppBar(
        title: const Text(
          "Flashcards",
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
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestoreService.getFlashcards(
                widget.userId,
                widget.subjectId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Aucune flashcard trouvée"));
                }

                return Scrollbar(
                  controller: _scrollController,
                  thickness: 4,
                  radius: const Radius.circular(10),
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onLongPress: () {
                          _showDeleteDialog(context, doc.id, data['front']);
                        },
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FlashcardViewPage(
                                  front: data['front'],
                                  back: data['back'],
                                  flashcardId: doc.id,
                                  subjectId: widget.subjectId,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            data['front'],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Colors.grey),
                  ),
                );
              },
            ),





          ),

          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'add',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFlashcardPage(
                          subjectId: widget.subjectId,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'review',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FlashcardReviewPage(
                          subjectId: widget.subjectId,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  },
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lightbulb, size: 32, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String flashcardId, String frontText) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la flashcard ?"),
        content: Text("Souhaitez-vous vraiment supprimer \"$frontText\" ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Supprimer"),
            onPressed: () async {
              await _firestoreService.deleteFlashcard(widget.userId, widget.subjectId, flashcardId);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
