import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/utils/responsive.dart';
import 'package:proctorly/screens/common_login_screen.dart';

// Student Dashboard
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const StudentHomePage(),
    const StudentTestsPage(),
    const StudentResultsPage(),
    const StudentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Notifications button
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
          // Profile/User menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'profile') {
                _showProfileDialog(context);
              } else if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Tests'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Results'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Student Dashboard';
      case 1:
        return 'Available Tests';
      case 2:
        return 'My Results';
      case 3:
        return 'Profile';
      default:
        return 'Student Dashboard';
    }
  }

  void _showProfileDialog(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Student Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, size: 48, color: Colors.blue),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Learner',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Name: ${user?.name ?? 'N/A'}'),
            Text('Email: ${user?.email ?? 'N/A'}'),
            Text('College ID: ${user?.collegeId ?? 'N/A'}'),
            Text('Department ID: ${user?.departmentId ?? 'N/A'}'),
            const Text('Role: Student'),
            const Text('Permissions: Take tests, view results'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Perform logout
              context.read<AuthProvider>().logout();
              // Navigate to login screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const CommonLoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Student Home Page
class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school, size: 32, color: AppConstants.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Welcome Student!',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Take tests, view your results, and track your progress.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Quick Stats
          const Text(
            'Your Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Consumer<TestResultProvider>(
            builder: (context, testResultProvider, child) {
              final user = context.read<AuthProvider>().currentUser;
              final userResults = user != null 
                  ? testResultProvider.getResultsForStudent(user.id)
                  : <TestResult>[];
              
              final testsTaken = userResults.length;
              final averageScore = userResults.isEmpty 
                  ? 0 
                  : (userResults.fold<int>(0, (sum, result) => sum + result.score) / userResults.length).round();
              final bestScore = userResults.isEmpty 
                  ? 0 
                  : userResults.map((r) => r.score).reduce((a, b) => a > b ? a : b);
              final totalTime = userResults.fold<int>(0, (sum, result) => sum + result.timeSpent);
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'Tests Taken',
                    testsTaken.toString(),
                    Icons.quiz,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Average Score',
                    '$averageScore%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Best Score',
                    '$bestScore%',
                    Icons.star,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Total Time',
                    '$totalTime min',
                    Icons.timer,
                    Colors.purple,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Student Tests Page
class StudentTestsPage extends StatelessWidget {
  const StudentTestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TestProvider>(
        builder: (context, testProvider, child) {
          final user = context.read<AuthProvider>().currentUser;
          final availableTests = testProvider.tests
              .where((test) => 
                  test.isActive && 
                  test.collegeId == user?.collegeId)
              .toList();

          if (availableTests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No tests available',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Tests will appear here when your teachers create them'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: availableTests.length,
            itemBuilder: (context, index) {
              final test = availableTests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.quiz, color: Colors.white),
                  ),
                  title: Text(
                    test.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(test.description),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${test.durationMinutes} minutes • Questions: ${test.questions.length}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Consumer<TestResultProvider>(
                    builder: (context, testResultProvider, child) {
                      final currentUser = context.read<AuthProvider>().currentUser;
                      final hasCompleted = currentUser != null && 
                          testResultProvider.getResultForTest(test.id, currentUser.id) != null;
                      
                      return ElevatedButton(
                        onPressed: (test.questions.isEmpty || hasCompleted) ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakeTestScreen(test: test),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasCompleted ? Colors.grey : null,
                          foregroundColor: hasCompleted ? Colors.white : null,
                        ),
                        child: Text(
                          test.questions.isEmpty 
                              ? 'No Questions' 
                              : hasCompleted 
                                  ? 'Completed' 
                                  : 'Start'
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Take Test Screen
class TakeTestScreen extends StatefulWidget {
  final Test test;
  
  const TakeTestScreen({
    super.key,
    required this.test,
  });

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, int> _answers = {};
  late DateTime _startTime;
  late DateTime _endTime;
  Test? _loadedTest;
  bool _isLoadingQuestions = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _endTime = _startTime.add(Duration(minutes: widget.test.durationMinutes));
    _loadTestQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Timer will trigger UI rebuild to update countdown
        });
        
        // Auto-submit when time is up
        final now = DateTime.now();
        if (now.isAfter(_endTime)) {
          timer.cancel();
          _submitTest();
        }
      }
    });
  }

  Future<void> _loadTestQuestions() async {
    try {
      // Check if we have placeholder questions
      final hasPlaceholderQuestions = widget.test.questions.isNotEmpty && 
          widget.test.questions.first.id.startsWith('placeholder_');
      
      if (hasPlaceholderQuestions) {
        // Fetch real questions from database
        final testRepository = context.read<TestProvider>().testRepository;
        final loadedTest = await testRepository.getTestById(widget.test.id);
        
        if (mounted) {
          setState(() {
            _loadedTest = loadedTest;
            _isLoadingQuestions = false;
          });
        }
      } else {
        // Already have real questions
        setState(() {
          _loadedTest = widget.test;
          _isLoadingQuestions = false;
        });
      }
    } catch (e) {
      print('Error loading test questions: $e');
      if (mounted) {
        setState(() {
          _isLoadingQuestions = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while fetching questions
    if (_isLoadingQuestions) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Test'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading test questions...'),
            ],
          ),
        ),
      );
    }

    // Use loaded test or fallback to original test
    final test = _loadedTest ?? widget.test;
    
    // Safety check for empty questions list
    if (test.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Test Error'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'This test has no questions available.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Please contact your teacher.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    final currentQuestion = test.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == test.questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_currentQuestionIndex + 1} of ${test.questions.length}'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Text(
                _getTimeRemaining(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.test.questions.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            const SizedBox(height: 20),
            
            // Question
            Text(
              currentQuestion.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.options.length,
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  final isSelected = _answers[currentQuestion.id] == index;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RadioListTile<int>(
                      title: Text(option.text),
                      value: index,
                      groupValue: _answers[currentQuestion.id],
                      onChanged: (value) {
                        setState(() {
                          _answers[currentQuestion.id] = value!;
                        });
                      },
                      selected: isSelected,
                    ),
                  );
                },
              ),
            ),
            
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                
                ElevatedButton(
                  onPressed: isLastQuestion ? _submitTest : _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion ? Colors.green : AppConstants.primaryColor,
                  ),
                  child: Text(isLastQuestion ? 'Submit Test' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRemaining() {
    final now = DateTime.now();
    final remaining = _endTime.difference(now);
    
    if (remaining.isNegative) {
      return 'Time Up!';
    }
    
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.test.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _submitTest() async {
    // Use the loaded test with real questions
    final test = _loadedTest ?? widget.test;
    
    // Calculate score and capture answers
    int correctAnswers = 0;
    List<Answer> studentAnswers = [];
    
    for (final question in test.questions) {
      final userAnswer = _answers[question.id];
      print('🔍 Answer Evaluation Debug:');
      print('  Question: ${question.text}');
      print('  User Answer Index: $userAnswer');
      print('  Correct Answer Index: ${question.correctAnswerIndex}');
      print('  Options: ${question.options.map((o) => o.text).toList()}');
      print('  User Selected: ${userAnswer != null ? question.options[userAnswer].text : 'No answer'}');
      print('  Correct Answer: ${question.options[question.correctAnswerIndex].text}');
      print('  Is Correct: ${userAnswer == question.correctAnswerIndex}');
      
      // Create answer record
      final studentAnswer = Answer(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + question.id,
        questionId: question.id,
        studentId: context.read<AuthProvider>().currentUser?.id ?? '',
        text: userAnswer != null ? question.options[userAnswer].text : 'No answer',
        isCorrect: userAnswer == question.correctAnswerIndex,
        submittedAt: DateTime.now(),
      );
      studentAnswers.add(studentAnswer);
      
      if (userAnswer == question.correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    final score = (correctAnswers / test.questions.length * 100).round();
    
    // Create test result
    final result = TestResult(
      id: '', // Let database generate UUID
      testId: test.id,
      studentId: context.read<AuthProvider>().currentUser?.id ?? '',
      testTitle: test.title,
      answers: studentAnswers,
      score: score,
      totalQuestions: test.questions.length,
      correctAnswers: correctAnswers,
      timeSpent: DateTime.now().difference(_startTime).inMinutes,
      submittedAt: DateTime.now(),
      completedAt: DateTime.now(),
      isSynced: false,
    );

    try {
      await context.read<TestResultProvider>().submitTestResult(result);
      
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestResultScreen(result: result, test: test),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting test: $e')),
        );
      }
    }
  }
}

// Test Result Screen
class TestResultScreen extends StatelessWidget {
  final TestResult result;
  final Test test;
  
  const TestResultScreen({
    super.key,
    required this.result,
    required this.test,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Test Title Card
            Card(
              color: AppConstants.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.quiz,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Result',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            test.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Score Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      '${result.score}%',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Correct', '${result.correctAnswers}/${result.totalQuestions}'),
                        _buildStatItem('Time', '${result.timeSpent} min'),
                        _buildStatItem('Date', _formatDate(result.submittedAt)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Performance Message
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _getPerformanceIcon(result.score),
                      size: 48,
                      color: _getPerformanceColor(result.score),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPerformanceMessage(result.score),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Answer Preview Section
            if (result.answers.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            color: AppConstants.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Answers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...result.answers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;
                        return _buildAnswerPreview(index + 1, answer, test);
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Tests'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showDetailedReview(context, result, test);
                    },
                    child: const Text('Review Answers'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  IconData _getPerformanceIcon(int score) {
    if (score >= 80) return Icons.star;
    if (score >= 60) return Icons.check_circle;
    return Icons.warning;
  }

  Color _getPerformanceColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getPerformanceMessage(int score) {
    if (score >= 80) return 'Excellent Work!';
    if (score >= 60) return 'Good Job!';
    return 'Keep Practicing!';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAnswerPreview(int questionNumber, Answer answer, Test test) {
    // Find the corresponding question
    final question = test.questions.firstWhere(
      (q) => q.id == answer.questionId,
      orElse: () => Question(
        id: answer.questionId,
        testId: test.id,
        text: 'Question not found',
        type: QuestionType.mcq,
        points: 1,
        order: 0,
        correctAnswerIndex: 0,
        options: [],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: answer.isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: answer.isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: answer.isCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Q$questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                answer.isCorrect ? Icons.check_circle : Icons.cancel,
                color: answer.isCorrect ? Colors.green : Colors.red,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your answer: ${answer.text}',
            style: TextStyle(
              fontSize: 13,
              color: answer.isCorrect ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!answer.isCorrect) ...[
            const SizedBox(height: 4),
            Text(
              'Correct answer: ${question.options[question.correctAnswerIndex].text}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDetailedReview(BuildContext context, TestResult result, Test test) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detailed Review - ${test.title}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: result.answers.length,
            itemBuilder: (context, index) {
              final answer = result.answers[index];
              return _buildAnswerPreview(index + 1, answer, test);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Student Results Page
class StudentResultsPage extends StatelessWidget {
  const StudentResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TestResultProvider>(
        builder: (context, resultProvider, child) {
          final user = context.read<AuthProvider>().currentUser;
          final myResults = resultProvider.results
              .where((result) => result.studentId == user?.id)
              .toList();

          if (myResults.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No results yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text('Your test results will appear here'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myResults.length,
            itemBuilder: (context, index) {
              final result = myResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Score Circle
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getScoreColor(result.score),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${result.score}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Test Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.testTitle.isNotEmpty ? result.testTitle : 'Test Result',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${result.score}%',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Correct: ${result.correctAnswers}/${result.totalQuestions}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Time: ${result.timeSpent} minutes',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Date
                      Text(
                        _formatDate(result.submittedAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Student Profile Page
class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        if (user == null) {
          return const Center(
            child: Text('No user data available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppConstants.primaryColor,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppConstants.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Student',
                          style: TextStyle(
                            color: AppConstants.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Profile Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Email', user.email),
                      _buildInfoRow('Phone', user.phone ?? 'Not provided'),
                      _buildInfoRow('Role', 'Student'),
                      _buildInfoRow('Year', user.year?.toString() ?? 'Not specified'),
                      _buildInfoRow('Student ID', user.studentId ?? 'Not assigned'),
                      _buildInfoRow('College ID', user.collegeId),
                      _buildInfoRow('Member Since', _formatDate(user.createdAt)),
                      _buildInfoRow('Last Login', _formatDate(user.lastLogin)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Profile editing functionality can be added here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile editing will be available soon')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Password change functionality can be added here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password change will be available soon')),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('Logout', style: TextStyle(color: Colors.red)),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CommonLoginScreen()),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
