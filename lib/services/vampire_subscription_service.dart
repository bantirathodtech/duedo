import 'dart:math';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import '../models/app_enums.dart';

final vampireSubscriptionServiceProvider = Provider((ref) => VampireSubscriptionService());

class VampireSubscription {
  final Obligation obligation;
  final double monthlyAmount;
  final double fiveYearOpportunityCost;
  final String platform; // 'Google Play', 'Apple App Store', 'Direct / Vendor'
  final String cancellationUrl;
  final String cancellationEmailTemplate;

  const VampireSubscription({
    required this.obligation,
    required this.monthlyAmount,
    required this.fiveYearOpportunityCost,
    required this.platform,
    required this.cancellationUrl,
    required this.cancellationEmailTemplate,
  });
}

class VampireSubscriptionService {
  /// Detects all recurring subscriptions and computes their 5-year compounded opportunity cost
  List<VampireSubscription> detectVampires(List<Obligation> obligations) {
    final vampires = <VampireSubscription>[];

    final subKeywords = [
      'netflix', 'spotify', 'prime', 'amazon prime', 'hotstar', 'disney',
      'youtube', 'gym', 'cult.fit', 'fitness', 'gold gym', 'apple music',
      'icloud', 'google one', 'chatgpt', 'openai', 'midjourney', 'adobe',
      'playstation', 'xbox', 'game pass', 'audible', 'tinder', 'bumble',
      'truecaller', 'canva', 'zoom', 'notion', 'patreon', 'substack'
    ];

    for (final ob in obligations) {
      if (!ob.isActive) continue;

      final titleLower = ob.title.toLowerCase();
      final categoryLower = ob.category.toLowerCase();

      final matchesKeyword = subKeywords.any((kw) => titleLower.contains(kw));
      final matchesCategory = categoryLower.contains('subscription') ||
          categoryLower.contains('entertainment') ||
          categoryLower.contains('fitness') ||
          (ob.type == ObligationType.recurring && !titleLower.contains('rent') && !titleLower.contains('insurance'));

      if (matchesKeyword || matchesCategory) {
        final monthly = ob.amount > 0 ? ob.amount : 500.0;
        final fiveYearCost = calculateFiveYearOpportunityCost(monthly);

        final isApple = Platform.isIOS || titleLower.contains('apple') || titleLower.contains('icloud');
        final isGoogle = Platform.isAndroid || titleLower.contains('google');

        String platform = 'Direct / Vendor';
        String cancelUrl = 'https://play.google.com/store/account/subscriptions';

        if (isApple) {
          platform = 'Apple App Store';
          cancelUrl = 'https://apps.apple.com/account/subscriptions';
        } else if (isGoogle) {
          platform = 'Google Play';
          cancelUrl = 'https://play.google.com/store/account/subscriptions';
        } else {
          platform = 'Direct / Provider';
          cancelUrl = 'https://www.google.com/search?q=how+to+cancel+${Uri.encodeComponent(ob.title)}+subscription';
        }

        final emailTemplate = '''
Subject: Immediate Cancellation Notice - ${ob.title}

Dear Support Team,

Please accept this as formal notice of immediate cancellation for my subscription/membership for "${ob.title}".

Account Name: Valued Subscriber
Obligation Reference: ${ob.id}
Effective Date: Immediately

I request that recurring billing and auto-debit charges be stopped immediately and written confirmation of cancellation be provided.

Thank you.
''';

        vampires.add(VampireSubscription(
          obligation: ob,
          monthlyAmount: monthly,
          fiveYearOpportunityCost: fiveYearCost,
          platform: platform,
          cancellationUrl: cancelUrl,
          cancellationEmailTemplate: emailTemplate.trim(),
        ));
      }
    }

    // Sort by largest 5-year wealth drain first
    vampires.sort((a, b) => b.fiveYearOpportunityCost.compareTo(a.fiveYearOpportunityCost));
    return vampires;
  }

  /// Calculates 5-Year Compounded Opportunity Cost at 12% p.a. standard equity benchmark
  /// Formula: Monthly SIP Future Value: P * [((1 + r/12)^n - 1) / (r/12)] * (1 + r/12)
  double calculateFiveYearOpportunityCost(double monthlyPayment) {
    if (monthlyPayment <= 0) return 0.0;
    const r = 0.12 / 12.0; // 1% per month
    const n = 60; // 5 years
    final fvFactor = (pow(1.0 + r, n) - 1.0) / r * (1.0 + r);
    return (monthlyPayment * fvFactor).roundToDouble();
  }
}
