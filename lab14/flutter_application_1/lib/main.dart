import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Question Model
class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

// Cubit State
class QuizState {
  final int currentQuestionIndex;
  final List<int?> userAnswers;
  final List<Question> questions;

  QuizState({
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.questions,
  });

  QuizState copyWith({
    int? currentQuestionIndex,
    List<int?>? userAnswers,
  }) {
    return QuizState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      questions: questions,
    );
  }
}

// Cubit
class QuizCubit extends Cubit<QuizState> {
  QuizCubit()
      : super(QuizState(
          currentQuestionIndex: 0,
          userAnswers: List.generate(3, (_) => null),
          questions: [
            Question(
              text: "What is the capital of France?",
              options: ["Paris", "London", "Berlin", "Madrid"],
              correctAnswerIndex: 0,
            ),
            Question(
              text: "Which planet is known as the Red Planet?",
              options: ["Venus", "Mars", "Jupiter", "Saturn"],
              correctAnswerIndex: 1,
            ),
            Question(
              text: "What is 2 + 2?",
              options: ["3", "4", "5", "6"],
              correctAnswerIndex: 1,
            ),
          ],
        ));

  void selectAnswer(int answerIndex) {
    final newAnswers = List<int?>.from(state.userAnswers);
    newAnswers[state.currentQuestionIndex] = answerIndex;
    emit(state.copyWith(userAnswers: newAnswers));
  }

  void nextQuestion() {
    // Allow index to reach questions.length to trigger ResultScreen
    if (state.currentQuestionIndex <= state.questions.length - 1) {
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex + 1));
    }
  }

  void previousQuestion() {
    if (state.currentQuestionIndex > 0) {
      emit(state.copyWith(
          currentQuestionIndex: state.currentQuestionIndex - 1));
    }
  }

  int calculateScore() {
    int score = 0;
    for (int i = 0; i < state.questions.length; i++) {
      if (state.userAnswers[i] == state.questions[i].correctAnswerIndex) {
        score++;
      }
    }
    return score;
  }
}

// Main App
void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizCubit(),
      child: MaterialApp(
        title: 'Quiz App',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false, // Removes the debug banner
        home: const QuizScreen(),
      ),
    );
  }
}

// Quiz Screen
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App'),centerTitle: true,),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state.currentQuestionIndex >= state.questions.length) {
            return ResultScreen(score: context.read<QuizCubit>().calculateScore());
          }
          final question = state.questions[state.currentQuestionIndex];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${state.currentQuestionIndex + 1}/${state.questions.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  question.text,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ...question.options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return RadioListTile<int?>(
                    title: Text(option),
                    value: index,
                    groupValue: state.userAnswers[state.currentQuestionIndex],
                    onChanged: (value) {
                      context.read<QuizCubit>().selectAnswer(value!);
                    },
                  );
                }),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (state.currentQuestionIndex > 0)
                      ElevatedButton(
                        onPressed: () {
                          context.read<QuizCubit>().previousQuestion();
                        },
                        child: const Text('Previous'),
                      ),
                    ElevatedButton(
                      onPressed: state.userAnswers[state.currentQuestionIndex] == null
                          ? null
                          : () {
                              context.read<QuizCubit>().nextQuestion();
                            },
                      child: Text(
                        state.currentQuestionIndex < state.questions.length - 1
                            ? 'Next'
                            : 'Finish',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Result Screen
class ResultScreen extends StatelessWidget {
  final int score;

  const ResultScreen({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final totalQuestions = context.read<QuizCubit>().state.questions.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Score: $score/$totalQuestions',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizApp()),
                );
              },
              child: const Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}