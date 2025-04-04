import 'package:flutter/material.dart';
import 'package:sapient/services/firestore_services.dart';

class AddFlashcardPage extends StatefulWidget {
  final String subjectId;
  final String userId;

  const AddFlashcardPage({super.key, required this.subjectId, required this.userId});

  @override
  State<AddFlashcardPage> createState() => _AddFlashcardPageState();
}

class _AddFlashcardPageState extends State<AddFlashcardPage> {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une Flashcard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(
                labelText: 'Réponse',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final front = questionController.text.trim();
                final back = answerController.text.trim();
                if (front.isNotEmpty && back.isNotEmpty) {
                  await FirestoreService().addFlashcard(widget.userId, widget.subjectId, front, back);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Ajouter Flashcard'),
            ),
          ],
        ),
      ),




    );
  }
}
