import 'package:flutter/material.dart';
import 'package:little_forest/theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isImageCard;
  final String? imageTimestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isImageCard = false,
    this.imageTimestamp,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<ChatMessage> _messages = [
    const ChatMessage(text: '안녕하세요~ 좋은아침이에요 !', isUser: false),
    const ChatMessage(text: '오늘은 64명이 산책을 하고있어요 ~!', isUser: false),
  ];

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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    final responses = _getResponses(text.toLowerCase());

    await Future.delayed(const Duration(milliseconds: 300));

    for (final msg in responses) {
      if (!mounted) return;
      setState(() => _messages.add(msg));
      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (mounted) setState(() => _isTyping = false);
  }

  List<ChatMessage> _getResponses(String input) {
    if (input.contains('안녕') || input.contains('좋은아침')) {
      return [
        const ChatMessage(text: '안녕하세요~ 좋은아침이에요 !', isUser: false),
        const ChatMessage(text: '오늘은 64명이 산책을 하고있어요 ~!', isUser: false),
      ];
    }
    if (input.contains('뭐') || input.contains('뭘') || input.contains('추천')) {
      return [
        const ChatMessage(text: '저의 일상을 먼저 공유해볼게요!', isUser: false),
        const ChatMessage(
          text: '',
          isUser: false,
          isImageCard: true,
          imageTimestamp: '11:00',
        ),
        const ChatMessage(
          text: '저는 오늘 날씨가 좋아서 점심 전 산책을 다녀왔어요~',
          isUser: false,
        ),
        const ChatMessage(
          text:
              '새싹님에게도 산책 추천할게요!\n\n산책하기 좋은 날!\n오늘 날씨를 알려드릴게요~\n☀️ 낮 기온 23°C\n💧 습도 40%\n🌫️ 미세먼지 좋음',
          isUser: false,
        ),
      ];
    }
    if (input.contains('운동') || input.contains('헬스')) {
      return [
        const ChatMessage(
          text: '',
          isUser: false,
          isImageCard: true,
          imageTimestamp: '7:00',
        ),
        const ChatMessage(
          text: '와우~ 아침 운동을 하셨군요!! 정말 좋은 하루의 시작이에요',
          isUser: false,
        ),
        const ChatMessage(
          text: '다른 활동이 필요하다면 제가 추천해드릴게요!',
          isUser: false,
        ),
      ];
    }
    if (input.contains('산책')) {
      return [
        const ChatMessage(text: '산책은 정말 좋은 선택이에요~ 🌿', isUser: false),
        const ChatMessage(
          text: '오늘 날씨도 딱 좋아요!\n☀️ 낮 기온 23°C\n💧 습도 40%\n🌫️ 미세먼지 좋음',
          isUser: false,
        ),
      ];
    }
    return [
      const ChatMessage(text: '오늘도 작은 한 걸음을 내딛어봐요 🌱', isUser: false),
      const ChatMessage(text: '밖에 나가기 딱 좋은 날씨예요. 산책 어떠세요?', isUser: false),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f7f0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf0f7f0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Little Forest AI',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.forestDeep,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.forestDeep,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: msg.isImageCard
                ? _buildImageCard(msg.imageTimestamp ?? '')
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundImage: const AssetImage('assets/images/chatbot_profile.png'),
    );
  }

  Widget _buildImageCard(String timestamp) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.forestDeep,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(color: Colors.grey[200]),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                timestamp,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color(0xFFf0f7f0)),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _controller,
                enabled: !_isTyping,
                decoration: const InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isTyping ? null : _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isTyping ? Colors.grey : AppColors.forestDeep,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
