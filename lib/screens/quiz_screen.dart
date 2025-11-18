import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int index = 0;
  bool loading = true;
  bool answered = false;
  String feedback = "";
  int score = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final q = await ApiService.fetchQuestions();
    setState(() {
      questions = q;
      loading = false;
    });
  }

  void selectAnswer(String selected) {
    final correct = questions[index].correctAnswer;

    setState(() {
      answered = true;
      if (selected == correct) {
        score++;
        feedback = "Correct! ($correct)";
      } else {
        feedback = "Incorrect! Correct Answer: $correct";
      }
    });
  }

  void nextQuestion() {
    setState(() {
      index++;
      answered = false;
      feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (index >= questions.length) {
      return Scaffold(
        body: Center(
          child: Text(
            "Quiz Finished!\nYour Score: $score/${questions.length}",
            style: TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final q = questions[index];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz App")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${index + 1}/${questions.length}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 15),
            Text(q.question, style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ...q.options.map(
              (opt) => ElevatedButton(
                onPressed: answered ? null : () => selectAnswer(opt),
                child: Text(opt),
              ),
            ),
            SizedBox(height: 20),
            if (answered)
              Text(
                feedback,
                style: TextStyle(
                  fontSize: 18,
                  color: feedback.startsWith("Correct")
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            if (answered)
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text("Next Question"),
              ),
          ],
        ),
      ),
    );
  }
}
