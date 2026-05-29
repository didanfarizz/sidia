import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import 'assessment_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isDiagnosisCard;
  final Map<String, dynamic>? diagnosisData;

  ChatMessage({
    this.text = '',
    required this.isUser,
    this.isDiagnosisCard = false,
    this.diagnosisData,
  });
}

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic>? initialDiagnosis;

  const ChatScreen({super.key, this.initialDiagnosis});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasStarted = false;
  bool _isTyping = false;
  final List<ChatMessage> _messages = [];
  AiService? _aiService;
  String? _aiError;

  @override
  void initState() {
    super.initState();
    _initAiService();
    if (widget.initialDiagnosis != null) {
      _hasStarted = true;
      _messages.add(ChatMessage(
        text: 'Halo kembali! Berikut adalah hasil diagnosis terakhir Anda yang tersimpan:',
        isUser: false,
      ));
      _messages.add(ChatMessage(
        isUser: false,
        isDiagnosisCard: true,
        diagnosisData: widget.initialDiagnosis,
      ));
    }
  }

  Future<void> _initAiService() async {
    try {
      _aiService = AiService();
      if (widget.initialDiagnosis != null) {
        _aiService?.addContextFromDiagnosis(widget.initialDiagnosis!);
      }
    } catch (e) {
      setState(() {
        _aiError = e.toString();
      });
      debugPrint("AI Service Error: $e");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _startDiagnosis() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AssessmentScreen()),
    );
    if (result != null && result is Map<String, dynamic>) {
      _handleDiagnosisResult(result);
    }
  }

  void _handleDiagnosisResult(Map<String, dynamic> data) {
    // Berikan konteks ke AI
    _aiService?.addContextFromDiagnosis(data);
    
    setState(() {
      _messages.add(ChatMessage(
        text: 'Ini adalah hasil analisis berdasarkan data fisik dan gejala Anda:',
        isUser: false,
      ));
      _messages.add(ChatMessage(
        isUser: false,
        isDiagnosisCard: true,
        diagnosisData: data,
      ));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text;
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    if (_aiError != null) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: 'Fitur AI belum dapat digunakan karena terjadi kesalahan: $_aiError',
          isUser: false,
        ));
      });
      _scrollToBottom();
      return;
    }

    if (_aiService == null) {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: 'Sistem AI masih memuat...', isUser: false));
      });
      _scrollToBottom();
      return;
    }

    // Call real LLM
    final response = await _aiService!.sendMessage(text);
    
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),

            if (!_hasStarted)
              Expanded(child: _buildIntroScreen())
            else ...[
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _messages.length + (_isTyping ? 2 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildDateSeparator('Hari ini, ${TimeOfDay.now().format(context)}');
                    }
                    
                    final msgIndex = index - 1;
                    if (msgIndex < _messages.length) {
                      final msg = _messages[msgIndex];
                      if (msg.isDiagnosisCard && msg.diagnosisData != null) {
                        return _buildDiagnosticCardDynamic(msg.diagnosisData!);
                      }
                      
                      if (msg.isUser) {
                        return _buildUserMessage(msg.text, TimeOfDay.now().format(context));
                      } else {
                        return _buildAIMessage(
                          Text(
                            msg.text,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        );
                      }
                    }
                    
                    if (_isTyping) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: _buildTypingIndicator(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Quick Actions
              if (_hasStarted)
                Container(
                  color: AppColors.bgLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _startDiagnosis,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Diagnosis Ulang', style: TextStyle(fontFamily: 'Poppins')),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryNavy,
                            side: const BorderSide(color: AppColors.primaryNavy),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Input Area
              _buildInputArea(),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ───────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SIDIA Logo
          Image.asset(
            'assets/images/logo_sidia.png',
            width: 70,
            height: 28,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildTextLogo();
            },
          ),
        ],
      ),
    );
  }

  // ─── Intro Screen (Empty State) ────────────────────────
  Widget _buildIntroScreen() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Halo!',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Saya Asisten SIDIA Anda. Mari kita mulai proses penilaian risiko diabetes Anda untuk mendapatkan panduan medis yang tepat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _hasStarted = true;
                      _messages.add(ChatMessage(
                        text: 'Halo! Saya asisten SIDIA Anda. Mari kita mulai proses diagnosis atau silakan tanyakan pertanyaan seputar keluhan Anda.',
                        isUser: false,
                      ));
                    });
                    _startDiagnosis();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Mulai Diagnosis',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'SIDIA can make mistakes. Always consult your primary care physician for final medical decisions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Date Separator ────────────────────────────────────
  Widget _buildDateSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }

  // ─── AI Message ────────────────────────────────────────
  Widget _buildAIMessage(Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryNavy,
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SIDIA',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── User Message ──────────────────────────────────────
  Widget _buildUserMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Diagnostic Analysis Card Dynamic ──────────────────
  Widget _buildDiagnosticCardDynamic(Map<String, dynamic> data) {
    final status = data['status_diagnosis'] ?? 'Unknown';
    final severity = data['severity'] ?? 'N/A';
    final confidence = data['confidence_score'] ?? 'N/A';
    final recommendations = List<String>.from(data['recommendations'] ?? []);
    final primary = data['primary_assessment'] ?? status;
    
    Color valueColor = AppColors.primaryRed;
    if (status.toLowerCase().contains('rendah')) valueColor = AppColors.accentGreen;
    if (status.toLowerCase().contains('sedang')) valueColor = AppColors.accentOrange;

    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Diagnostic Analysis',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.assessment_outlined, size: 18, color: AppColors.accentBlue),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDiagnosticRow('Primary\nCondition', primary, isBold: true),
                const Divider(color: AppColors.borderLight, height: 24),
                _buildDiagnosticRow('Risk Level', status, valueColor: valueColor),
                const Divider(color: AppColors.borderLight, height: 24),
                _buildDiagnosticRow('Certainty Factor (%)', severity, valueColor: valueColor),
                const Divider(color: AppColors.borderLight, height: 24),
                _buildDiagnosticRow('Confidence Score', confidence, valueColor: AppColors.accentBlue),
              ],
            ),
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(
                    color: AppColors.accentOrange,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommendation:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recommendations.first,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ─── Typing Indicator ──────────────────────────────────
  Widget _buildTypingIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text(
            '...',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Input Area ────────────────────────────────────────
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgGrey,
                ),
                child: const Icon(Icons.add, color: AppColors.textSecondary, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgGrey,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message or describe\nsymptoms...',
                      hintMaxLines: 2,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      hintStyle: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textLight,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentBlue,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'SIDIA can make mistakes. Always consult your primary care physician for final medical decisions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          'SI',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
        Text(
          'D',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryRed,
          ),
        ),
        Text(
          'IA',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryNavy,
          ),
        ),
      ],
    );
  }
}
