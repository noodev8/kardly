import 'package:flutter/material.dart';

class TradingProvider extends ChangeNotifier {
  List<TradeRequest> _availableTrades = [];
  List<TradeRequest> _myTrades = [];
  List<TradeMessage> _messages = [];
  bool _isLoading = false;

  List<TradeRequest> get availableTrades => _availableTrades;
  List<TradeRequest> get myTrades => _myTrades;
  List<TradeMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  int get activeTrades => _myTrades.where((trade) => trade.status == TradeStatus.active).length;
  int get completedTrades => _myTrades.where((trade) => trade.status == TradeStatus.completed).length;
  double get traderRating => 4.8; // Mock rating

  Future<void> loadTradingData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Load from API
      await Future.delayed(const Duration(seconds: 1));
      
      _availableTrades = _generateMockTrades();
      _myTrades = _generateMockMyTrades();
      _messages = _generateMockMessages();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTradeRequest(String offering, String wanting) async {
    // TODO: Implement trade creation
    await Future.delayed(const Duration(seconds: 1));
    
    final newTrade = TradeRequest(
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}',
      traderId: 'current_user',
      traderName: 'You',
      traderRating: traderRating,
      tradeCount: completedTrades,
      offering: offering,
      wanting: wanting,
      status: TradeStatus.active,
      createdAt: DateTime.now(),
      responses: 0,
    );
    
    _myTrades.insert(0, newTrade);
    notifyListeners();
  }

  List<TradeRequest> _generateMockTrades() {
    return List.generate(10, (index) {
      return TradeRequest(
        id: 'trade_$index',
        traderId: 'user_$index',
        traderName: 'User${index + 1}',
        traderRating: 4.5 + (index % 3) * 0.1,
        tradeCount: 15 + index * 3,
        offering: 'NewJeans Haerin - Get Up',
        wanting: 'BLACKPINK Jennie - Born Pink',
        status: TradeStatus.active,
        createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
        responses: index + 1,
      );
    });
  }

  List<TradeRequest> _generateMockMyTrades() {
    return List.generate(3, (index) {
      return TradeRequest(
        id: 'my_trade_$index',
        traderId: 'current_user',
        traderName: 'You',
        traderRating: traderRating,
        tradeCount: completedTrades,
        offering: 'aespa Karina - MY WORLD',
        wanting: 'IVE Wonyoung - LOVE DIVE',
        status: index == 0 ? TradeStatus.active : index == 1 ? TradeStatus.pending : TradeStatus.completed,
        createdAt: DateTime.now().subtract(Duration(days: index + 1)),
        responses: index + 2,
      );
    });
  }

  List<TradeMessage> _generateMockMessages() {
    return List.generate(5, (index) {
      return TradeMessage(
        id: 'message_$index',
        userId: 'user_$index',
        userName: 'User${index + 1}',
        lastMessage: index % 2 == 0 
            ? 'Hi! I\'m interested in your NewJeans card'
            : 'Thanks for the trade! 5 stars ⭐',
        timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
        isUnread: index < 2,
      );
    });
  }
}

class TradeRequest {
  final String id;
  final String traderId;
  final String traderName;
  final double traderRating;
  final int tradeCount;
  final String offering;
  final String wanting;
  final TradeStatus status;
  final DateTime createdAt;
  final int responses;

  TradeRequest({
    required this.id,
    required this.traderId,
    required this.traderName,
    required this.traderRating,
    required this.tradeCount,
    required this.offering,
    required this.wanting,
    required this.status,
    required this.createdAt,
    required this.responses,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

class TradeMessage {
  final String id;
  final String userId;
  final String userName;
  final String lastMessage;
  final DateTime timestamp;
  final bool isUnread;

  TradeMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.lastMessage,
    required this.timestamp,
    required this.isUnread,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

enum TradeStatus {
  active,
  pending,
  completed,
  cancelled,
}
