import '../../services/database.dart';

enum NegotiationType {
  aprReduction,
  feeWaiver,
  foreclosureWaiver,
  graceBuffer,
}

class DebtNegotiationScript {
  final NegotiationType type;
  final String title;
  final String rbiReference;
  final String strategyHook;
  final String teleprompterScript;
  final String customerCareNumber;

  const DebtNegotiationScript({
    required this.type,
    required this.title,
    required this.rbiReference,
    required this.strategyHook,
    required this.teleprompterScript,
    required this.customerCareNumber,
  });
}

class DebtNegotiationService {
  static const Map<String, String> bankHelplines = {
    'hdfc': '18002026161',
    'sbi': '18001801290',
    'icici': '18001080',
    'axis': '18604195555',
    'kotak': '18602662666',
    'citi': '18602102484',
    'standard chartered': '18003451000',
    'rbl': '18001206161',
    'onecard': '18002103456',
  };

  /// Generates tailored negotiation scripts grounded in RBI guidelines
  static List<DebtNegotiationScript> generateScripts({
    required Obligation obligation,
    int paymentStreak = 0,
    String? accountSuffix,
  }) {
    final scripts = <DebtNegotiationScript>[];
    final bankKey = _detectBankKey(obligation.title, obligation.category);
    final helpline = bankHelplines[bankKey] ?? '18001200';
    final suffix = accountSuffix ?? 'XXXX';
    final apr = obligation.interestRate > 0 ? '${obligation.interestRate.toStringAsFixed(1)}%' : '42%';

    // 1. APR Reduction Script
    scripts.add(DebtNegotiationScript(
      type: NegotiationType.aprReduction,
      title: 'High-APR Reduction to Prime Rate',
      rbiReference: 'RBI Master Direction - Credit Card and Debit Card Issuance (2022)',
      strategyHook: 'Leverage your prompt payment streak and threaten balance transfer to a 11.5% loan.',
      customerCareNumber: helpline,
      teleprompterScript: '''
"Hello, I am calling regarding my account ending in $suffix. 

I have maintained a consistent payment track record ($paymentStreak consecutive billing cycles paid on time). However, my current interest rate of $apr is excessively punitive compared to current prime balance transfer offers available to me at 11.5% to 14%.

Under the RBI Fair Practices Code, I am requesting that my account be reviewed by a retention manager and converted to a prime rate tier or low-interest EMI schedule. 

If this account cannot be re-priced, please initiate the pre-closure and No Objection Certificate (NOC) process, as I will be transferring the outstanding balance to a competing lender this week."
'''.trim(),
    ));

    // 2. Annual Fee & Charges Waiver
    scripts.add(DebtNegotiationScript(
      type: NegotiationType.feeWaiver,
      title: 'Annual Fee & Surcharge Reversal',
      rbiReference: 'RBI Guidelines on Unsolicited Commercial Charges & Transparency',
      strategyHook: 'Banks routinely reverse annual fees for active users within 120 seconds.',
      customerCareNumber: helpline,
      teleprompterScript: '''
"Hello, I am calling regarding the annual maintenance fee / surcharge levied on my account ending in $suffix.

As an active cardholder who consistently services obligations, I would like this fee reversed on a courtesy basis. Competitor institutions offer lifetime-free alternatives with equivalent benefits.

Please register a service request for a 100% fee waiver. If the system requires manual retention override, please escalate this to your supervisor immediately."
'''.trim(),
    ));

    // 3. Foreclosure & Pre-Payment Charges Waiver
    scripts.add(DebtNegotiationScript(
      type: NegotiationType.foreclosureWaiver,
      title: 'Foreclosure / Pre-Payment Penalty Waiver',
      rbiReference: 'RBI Circular DBOD.No.Dir.BC.107/13.03.00/2011-12',
      strategyHook: 'RBI strictly prohibits foreclosure penalties on floating rate retail loans.',
      customerCareNumber: helpline,
      teleprompterScript: '''
"Hello, I am calling regarding loan account ending in $suffix. I intend to make an accelerated pre-payment / total foreclosure.

Please confirm that zero foreclosure charges or pre-payment penalties will be levied, as mandated by RBI Circular DBOD.No.Dir.BC.107/13.03.00/2011-12 which explicitly prohibits banks and NBFCs from charging foreclosure penalties on individual retail loans.

Please generate my exact foreclosure statement and principal payoff balance with zero penalty fees."
'''.trim(),
    ));

    // 4. Emergency Grace Shield Buffer
    scripts.add(DebtNegotiationScript(
      type: NegotiationType.graceBuffer,
      title: 'Emergency Grace Period (Credit Score Defense)',
      rbiReference: 'RBI Prudential Norms on Income Recognition and Asset Classification (IRAC)',
      strategyHook: 'Request a 7-10 day technical grace extension before CIBIL bureau reporting.',
      customerCareNumber: helpline,
      teleprompterScript: '''
"Hello, I am calling proactively regarding my upcoming obligation for account $suffix due shortly.

Due to a temporary banking technical settlement delay, my funds will clear within the next 7 business days. As per RBI IRAC guidelines, an account is not classified as an SMA/NPA until overdue thresholds are breached.

I am requesting an official 7-day grace memorandum noted on my account so no late penalty is levied and no adverse bureau report is submitted to CIBIL / Experian. Please provide the service request reference number for this note."
'''.trim(),
    ));

    return scripts;
  }

  static String _detectBankKey(String title, String category) {
    final combined = '${title.toLowerCase()} ${category.toLowerCase()}';
    for (final key in bankHelplines.keys) {
      if (combined.contains(key)) return key;
    }
    return 'generic';
  }
}
