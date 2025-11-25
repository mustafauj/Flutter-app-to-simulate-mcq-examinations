import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:proctorly/providers/providers.dart';
import 'package:proctorly/models/models.dart';
import 'package:proctorly/utils/constants.dart';
import 'package:proctorly/utils/responsive.dart';

// Professional Test Creation Screen with Multi-Step Wizard
class ProfessionalTestCreationScreen extends StatefulWidget {
  final Test? testToEdit;
  
  const ProfessionalTestCreationScreen({super.key, this.testToEdit});

  @override
  State<ProfessionalTestCreationScreen> createState() => _ProfessionalTestCreationScreenState();
}

class _ProfessionalTestCreationScreenState extends State<ProfessionalTestCreationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Test Basic Information
  final _testTitleController = TextEditingController();
  final _testDescriptionController = TextEditingController();
  final _totalMarksController = TextEditingController();
  final _questionCountController = TextEditingController();
  final _durationController = TextEditingController();
  
  // Test Configuration
  int _totalMarks = 0;
  int _questionCount = 0;
  int _durationMinutes = 60;
  DateTime? _startTime;
  DateTime? _endTime;
  
  // Questions Management
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  
  // Form Keys
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _questionFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeTestData();
  }

  void _initializeTestData() {
    if (widget.testToEdit != null) {
      final test = widget.testToEdit!;
      _testTitleController.text = test.title;
      _testDescriptionController.text = test.description;
      _totalMarksController.text = _calculateTotalMarks(test.questions).toString();
      _questionCountController.text = test.questions.length.toString();
      _durationController.text = test.durationMinutes.toString();
      _questions = List.from(test.questions);
      _totalMarks = _calculateTotalMarks(test.questions);
      _questionCount = test.questions.length;
      _durationMinutes = test.durationMinutes;
    } else {
      _questionCountController.text = '1';
      _totalMarksController.text = '10';
      _durationController.text = '60';
      _addInitialQuestion();
    }
  }

  int _calculateTotalMarks(List<Question> questions) {
    return questions.fold(0, (sum, question) => sum + question.points);
  }

  void _addInitialQuestion() {
    if (_questions.isEmpty) {
      _questions.add(_createEmptyQuestion(0));
    }
  }

  Question _createEmptyQuestion(int order) {
    return Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: '',
      text: '',
      type: QuestionType.mcq,
      options: [
        Answer(
          id: 'opt1_${DateTime.now().millisecondsSinceEpoch}',
          questionId: '',
          studentId: '',
          text: '',
          isCorrect: false,
          submittedAt: DateTime.now(),
        ),
        Answer(
          id: 'opt2_${DateTime.now().millisecondsSinceEpoch}',
          questionId: '',
          studentId: '',
          text: '',
          isCorrect: false,
          submittedAt: DateTime.now(),
        ),
        Answer(
          id: 'opt3_${DateTime.now().millisecondsSinceEpoch}',
          questionId: '',
          studentId: '',
          text: '',
          isCorrect: false,
          submittedAt: DateTime.now(),
        ),
        Answer(
          id: 'opt4_${DateTime.now().millisecondsSinceEpoch}',
          questionId: '',
          studentId: '',
          text: '',
          isCorrect: false,
          submittedAt: DateTime.now(),
        ),
      ],
      correctAnswerIndex: 0,
      points: 1,
      order: order,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayoutBuilder(
      builder: (context, screenType) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: ResponsiveText(
              widget.testToEdit != null ? 'Edit Test' : 'Create New Test',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: Responsive.getResponsiveAppBarHeight(context),
        actions: [
          // Removed duplicate save button - using navigation button instead
        ],
      ),
          body: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(context),
              
              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildBasicInfoStep(context),
                    _buildQuestionManagementStep(context),
                    _buildTestPreviewStep(context),
                  ],
                ),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildProgressStep(0, 'Basic Info', Icons.info_outline),
              _buildProgressLine(),
              _buildProgressStep(1, 'Questions', Icons.quiz_outlined),
              _buildProgressLine(),
              _buildProgressStep(2, 'Preview', Icons.preview_outlined),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getStepTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int stepIndex, String title, IconData icon) {
    final isActive = _currentStep >= stepIndex;
    final isCurrent = _currentStep == stepIndex;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? AppConstants.primaryColor : Colors.grey[300],
              shape: BoxShape.circle,
              border: isCurrent ? Border.all(color: AppConstants.primaryColor, width: 3) : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine() {
    return Container(
      height: 2,
      width: 40,
      color: _currentStep > 0 ? AppConstants.primaryColor : Colors.grey[300],
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Enter test basic information';
      case 1:
        return 'Create and manage questions';
      case 2:
        return 'Review and finalize your test';
      default:
        return '';
    }
  }

  Widget _buildBasicInfoStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _basicInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Title
            _buildSectionCard(
              'Test Information',
              Icons.assignment_outlined,
              [
                _buildTextField(
                  controller: _testTitleController,
                  label: 'Test Title',
                  hint: 'Enter a descriptive title for your test',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Test title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _testDescriptionController,
                  label: 'Description',
                  hint: 'Provide a brief description of the test',
                  maxLines: 3,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Test Configuration
            _buildSectionCard(
              'Test Configuration',
              Icons.settings_outlined,
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _questionCountController,
                        label: 'Number of Questions',
                        hint: 'e.g., 10',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final count = int.tryParse(value);
                          if (count == null || count < 1) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final count = int.tryParse(value);
                          if (count != null && count > 0) {
                            setState(() {
                              _questionCount = count;
                              _adjustQuestionsList(count);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _totalMarksController,
                        label: 'Total Marks',
                        hint: 'e.g., 100',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          final marks = int.tryParse(value);
                          if (marks == null || marks < 1) {
                            return 'Must be at least 1';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final marks = int.tryParse(value);
                          if (marks != null && marks > 0) {
                            setState(() {
                              _totalMarks = marks;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _durationController,
                  label: 'Duration (minutes)',
                  hint: 'e.g., 60',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Duration is required';
                    }
                    final duration = int.tryParse(value);
                    if (duration == null || duration < 1) {
                      return 'Must be at least 1 minute';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final duration = int.tryParse(value);
                    if (duration != null && duration > 0) {
                      setState(() {
                        _durationMinutes = duration;
                      });
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Schedule Information
            _buildSectionCard(
              'Schedule',
              Icons.schedule_outlined,
              [
                ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.green),
                  title: const Text(
                    'Start Time',
                    style: TextStyle(color: Colors.black87),
                  ),
                  subtitle: Text(
                    _startTime != null 
                        ? _formatDateTime(_startTime!)
                        : 'Click to set start time',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectStartTime,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.stop, color: Colors.red),
                  title: const Text(
                    'End Time',
                    style: TextStyle(color: Colors.black87),
                  ),
                  subtitle: Text(
                    _endTime != null 
                        ? _formatDateTime(_endTime!)
                        : 'Click to set end time',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectEndTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionManagementStep(BuildContext context) {
    return Column(
      children: [
        // Question Navigation Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              IconButton(
                onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: _currentQuestionIndex < _questions.length - 1 ? _nextQuestion : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        
        // Question Editor
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _questionFormKey,
              child: _buildQuestionEditor(),
            ),
          ),
        ),
        
        // Question Actions
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addNewQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Question'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _questions.length > 1 ? _deleteCurrentQuestion : null,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTestPreviewStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test Summary
          _buildSectionCard(
            'Test Summary',
            Icons.summarize_outlined,
            [
              _buildSummaryRow('Title', _testTitleController.text),
              _buildSummaryRow('Description', _testDescriptionController.text),
              _buildSummaryRow('Total Questions', _questions.length.toString()),
              _buildSummaryRow('Total Marks', _totalMarks.toString()),
              _buildSummaryRow('Duration', '$_durationMinutes minutes'),
              _buildSummaryRow('Start Time', _startTime != null ? _formatDateTime(_startTime!) : 'Not set'),
              _buildSummaryRow('End Time', _endTime != null ? _formatDateTime(_endTime!) : 'Not set'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Questions Preview
          _buildSectionCard(
            'Questions Preview',
            Icons.quiz_outlined,
            [
              ...List.generate(_questions.length, (index) {
                final question = _questions[index];
                return _buildQuestionPreviewCard(question, index);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionEditor() {
    if (_questions.isEmpty) return const SizedBox();
    
    final currentQuestion = _questions[_currentQuestionIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question Text
        _buildTextField(
          controller: TextEditingController(text: currentQuestion.text),
          label: 'Question Text',
          hint: 'Enter your question here...',
          maxLines: 3,
          onChanged: (value) {
            _updateCurrentQuestion(text: value);
          },
        ),
        
        const SizedBox(height: 20),
        
        // Question Points
        _buildTextField(
          controller: TextEditingController(text: currentQuestion.points.toString()),
          label: 'Points for this question',
          hint: 'e.g., 5',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            final points = int.tryParse(value);
            if (points != null && points > 0) {
              _updateCurrentQuestion(points: points);
            }
          },
        ),
        
        const SizedBox(height: 20),
        
        // Answer Options
        Text(
          'Answer Options',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        ...List.generate(currentQuestion.options.length, (index) {
          return _buildAnswerOption(index, currentQuestion);
        }),
        
        const SizedBox(height: 20),
        
        // Correct Answer Selection
        Row(
          children: [
            Text(
              'Select Correct Answer',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            if (currentQuestion.correctAnswerIndex >= 0 && currentQuestion.correctAnswerIndex < currentQuestion.options.length)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✓ Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⚠ Incomplete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        ...List.generate(currentQuestion.options.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: currentQuestion.correctAnswerIndex == index 
                    ? AppConstants.primaryColor 
                    : Colors.grey[300]!,
                width: currentQuestion.correctAnswerIndex == index ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: currentQuestion.correctAnswerIndex == index 
                  ? AppConstants.primaryColor.withOpacity(0.05)
                  : Colors.white,
            ),
            child: RadioListTile<int>(
              title: Text(
                'Option ${String.fromCharCode(65 + index)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: currentQuestion.correctAnswerIndex == index 
                      ? AppConstants.primaryColor 
                      : Colors.black87,
                ),
              ),
              subtitle: Text(
                currentQuestion.options[index].text.isEmpty 
                    ? 'Enter option text above' 
                    : currentQuestion.options[index].text,
                style: TextStyle(
                  color: currentQuestion.correctAnswerIndex == index 
                      ? AppConstants.primaryColor 
                      : Colors.grey[600],
                ),
              ),
              value: index,
              groupValue: currentQuestion.correctAnswerIndex,
              activeColor: AppConstants.primaryColor,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _updateCurrentQuestion(correctAnswerIndex: value);
                  });
                }
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnswerOption(int index, Question question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: question.options[index].text),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Enter option ${String.fromCharCode(65 + index)}',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _updateAnswerOption(index, value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPreviewCard(Question question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${question.points} points',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.text.isEmpty ? 'No question text' : question.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (optionIndex) {
            final option = question.options[optionIndex];
            final isCorrect = optionIndex == question.correctAnswerIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: isCorrect ? Border.all(color: Colors.green) : null,
              ),
              child: Row(
                children: [
                  Text(
                    '${String.fromCharCode(65 + optionIndex)}. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      option.text.isEmpty ? 'No option text' : option.text,
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.grey[700],
                      ),
                    ),
                  ),
                  if (isCorrect)
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _canProceedToNextStep() ? (_currentStep == 2 ? _saveTest : _nextStep) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceedToNextStep() 
                        ? AppConstants.primaryColor 
                        : Colors.grey[400],
                    foregroundColor: _canProceedToNextStep() 
                        ? Colors.white 
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: _canProceedToNextStep() ? 2 : 0,
                  ),
                  child: Text(_currentStep == 2 ? 'Save Test' : 'Next'),
                ),
                if (_currentStep == 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getValidationMessage(),
                      style: TextStyle(
                        color: _canProceedToNextStep() ? Colors.green[600] : Colors.red[600],
                        fontSize: 12,
                        fontWeight: _canProceedToNextStep() ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Methods
  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else if (_currentStep == 2) {
      // On the final step, save the test
      _saveTest();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // Validation Methods
  String _getValidationMessage() {
    if (_questions.isEmpty) {
      return 'Add at least one question to continue';
    }
    
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      
      if (question.text.trim().isEmpty) {
        return 'Complete Question ${i + 1}: Enter question text';
      }
      
      for (int j = 0; j < question.options.length; j++) {
        if (question.options[j].text.trim().isEmpty) {
          return 'Complete Question ${i + 1}: Fill option ${String.fromCharCode(65 + j)}';
        }
      }
      
      if (question.correctAnswerIndex < 0 || question.correctAnswerIndex >= question.options.length) {
        return 'Complete Question ${i + 1}: Select correct answer';
      }
    }
    
    return '✓ All questions completed! Ready to preview';
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _testTitleController.text.trim().isNotEmpty &&
               _questionCountController.text.trim().isNotEmpty &&
               _totalMarksController.text.trim().isNotEmpty &&
               _durationController.text.trim().isNotEmpty;
      case 1:
        return _questions.isNotEmpty && _questions.every((q) => 
               q.text.trim().isNotEmpty && 
               q.options.every((opt) => opt.text.trim().isNotEmpty) &&
               q.correctAnswerIndex >= 0 && q.correctAnswerIndex < q.options.length);
      case 2:
        return true; // Preview step, always can proceed
      default:
        return false;
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _basicInfoFormKey.currentState?.validate() ?? false;
      case 1:
        return _questionFormKey.currentState?.validate() ?? false;
      case 2:
        return true;
      default:
        return false;
    }
  }

  // Helper Methods
  void _adjustQuestionsList(int targetCount) {
    if (targetCount > _questions.length) {
      // Add new questions
      for (int i = _questions.length; i < targetCount; i++) {
        _questions.add(_createEmptyQuestion(i));
      }
    } else if (targetCount < _questions.length) {
      // Remove excess questions
      _questions = _questions.take(targetCount).toList();
      if (_currentQuestionIndex >= _questions.length) {
        _currentQuestionIndex = _questions.length - 1;
      }
    }
  }

  void _updateCurrentQuestion({
    String? text,
    int? points,
    int? correctAnswerIndex,
  }) {
    if (_currentQuestionIndex < _questions.length) {
      final currentQuestion = _questions[_currentQuestionIndex];
      _questions[_currentQuestionIndex] = currentQuestion.copyWith(
        text: text ?? currentQuestion.text,
        points: points ?? currentQuestion.points,
        correctAnswerIndex: correctAnswerIndex ?? currentQuestion.correctAnswerIndex,
      );
    }
  }

  void _updateAnswerOption(int optionIndex, String text) {
    if (_currentQuestionIndex < _questions.length) {
      final currentQuestion = _questions[_currentQuestionIndex];
      final updatedOptions = List<Answer>.from(currentQuestion.options);
      if (optionIndex < updatedOptions.length) {
        updatedOptions[optionIndex] = updatedOptions[optionIndex].copyWith(text: text);
        _questions[_currentQuestionIndex] = currentQuestion.copyWith(options: updatedOptions);
      }
    }
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(_createEmptyQuestion(_questions.length));
      _currentQuestionIndex = _questions.length - 1;
    });
  }

  void _deleteCurrentQuestion() {
    if (_questions.length > 1) {
      setState(() {
        _questions.removeAt(_currentQuestionIndex);
        if (_currentQuestionIndex >= _questions.length) {
          _currentQuestionIndex = _questions.length - 1;
        }
      });
    }
  }

  Future<void> _selectStartTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime ?? (_startTime ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: _startTime ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime ?? DateTime.now().add(const Duration(hours: 1))),
      );
      
      if (time != null) {
        setState(() {
          _endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveTest() async {
    print('🔍 _saveTest: Starting test save process');
    
    if (!_validateCurrentStep()) {
      print('❌ _saveTest: Validation failed');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AuthProvider>().currentUser;
      print('👤 _saveTest: Current user: ${currentUser?.name} (ID: ${currentUser?.id})');
      print('🏫 _saveTest: College ID: ${currentUser?.collegeId}');
      print('📚 _saveTest: Department ID: ${currentUser?.departmentId}');
      print('📝 _saveTest: Questions count: ${_questions.length}');
      
      final test = Test(
        id: widget.testToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _testTitleController.text.trim(),
        description: _testDescriptionController.text.trim(),
        createdBy: currentUser!.id,
        collegeId: currentUser.collegeId,
        departmentId: currentUser.departmentId ?? '',
        targetYears: null,
        startTime: _startTime ?? DateTime.now(),
        endTime: _endTime ?? DateTime.now().add(Duration(minutes: _durationMinutes)),
        durationMinutes: _durationMinutes,
        status: TestStatus.draft,
        questions: _questions,
        createdAt: widget.testToEdit?.createdAt ?? DateTime.now(),
        publishedAt: widget.testToEdit?.publishedAt,
        isActive: true,
      );

      print('📋 _saveTest: Test object created - Title: ${test.title}');
      print('📋 _saveTest: Test ID: ${test.id}');

      if (widget.testToEdit != null) {
        print('🔄 _saveTest: Updating existing test');
        await context.read<TestProvider>().updateTest(test);
      } else {
        print('➕ _saveTest: Creating new test');
        await context.read<TestProvider>().createTest(test);
      }
      
      print('✅ _saveTest: Test saved successfully');

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.testToEdit != null 
                ? 'Test updated successfully' 
                : 'Test created successfully'),
          ),
        );
      }
    } catch (e) {
      print('❌ _saveTest: Error occurred: $e');
      print('❌ _saveTest: Error type: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving test: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _testTitleController.dispose();
    _testDescriptionController.dispose();
    _totalMarksController.dispose();
    _questionCountController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}

// Extension to add copyWith method to Answer class
extension AnswerCopyWith on Answer {
  Answer copyWith({
    String? id,
    String? questionId,
    String? studentId,
    String? text,
    bool? isCorrect,
    DateTime? submittedAt,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      studentId: studentId ?? this.studentId,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
