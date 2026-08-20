class WingmanRequest {
  final String situation;
  final String goal;

  const WingmanRequest({
    required this.situation,
    required this.goal,
  });

  Map<String, dynamic> toJson() => {
        'situation': situation,
        'goal': goal,
      };
}

class WingmanOption {
  final String tone;
  final String replyText;

  const WingmanOption({
    required this.tone,
    required this.replyText,
  });

  factory WingmanOption.fromJson(Map<String, dynamic> json) {
    return WingmanOption(
      tone: json['tone'] as String? ?? 'Suggested Reply',
      replyText: json['replyText'] as String? ?? '',
    );
  }
}

class WingmanResponse {
  final List<WingmanOption> options;

  const WingmanResponse({required this.options});

  factory WingmanResponse.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final parsedOptions = rawOptions
        .map((e) => WingmanOption.fromJson(e as Map<String, dynamic>))
        .toList();

    return WingmanResponse(options: parsedOptions);
  }
}
