/// OpenAI模型枚举 - 预定义常用模型
abstract class AIModels {
  static const gemini3ProPreview = 'google/gemini-3-pro-preview';
  static const gpt5 = 'gpt-5';
  static const gpt5Nano = 'gpt-5-nano';
  static const gpt4oMini = 'gpt-4o-mini';
}

/// OpenAI角色枚举
enum OpenAIRole {
  system('system'),
  user('user'),
  assistant('assistant');

  const OpenAIRole(this.value);
  final String value;
}

enum OpenAIMessageType {
  reasoning('reasoning'),
  message('message');

  const OpenAIMessageType(this.value);
  final String value;
}

enum OpenAIReasoningEffort {
  minimal('minimal'),
  low('low'),
  medium('medium'),
  high('high'),
  ;

  const OpenAIReasoningEffort(this.value);
  final String value;
}

class OpenAIReasoning {
  final OpenAIReasoningEffort? effort;
  final String? summary;

  const OpenAIReasoning({this.effort, this.summary});

  factory OpenAIReasoning.fromJson(Map<String, dynamic> json) {
    final effortValue = json['effort'] as String?;
    return OpenAIReasoning(
      effort: effortValue != null
          ? OpenAIReasoningEffort.values.firstWhere(
              (e) => e.value == effortValue,
              orElse: () => OpenAIReasoningEffort.minimal,
            )
          : null,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (effort != null) 'effort': effort!.value,
        if (summary != null) 'summary': summary,
      };
}

class OpenAIInput {
  final String? role;
  final String? content;

  const OpenAIInput({this.role, this.content});

  factory OpenAIInput.fromJson(Map<String, dynamic> json) {
    return OpenAIInput(
      role: json['role'] as String?,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role,
        if (content != null) 'content': content,
      };
}

class OpenAIOutputContent {
  final String? type;
  final String? text;
  final List<dynamic>? annotations;
  final List<dynamic>? logprobs;

  const OpenAIOutputContent({
    this.type,
    this.text,
    this.annotations,
    this.logprobs,
  });

  factory OpenAIOutputContent.fromJson(Map<String, dynamic> json) {
    return OpenAIOutputContent(
      type: json['type'] as String?,
      text: json['text'] as String?,
      annotations: json['annotations'] as List<dynamic>?,
      logprobs: json['logprobs'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (text != null) 'text': text,
        if (annotations != null) 'annotations': annotations,
        if (logprobs != null) 'logprobs': logprobs,
      };
}

/// OpenAI聊天消息模型
class OpenAIOutput {
  final String? id;
  final OpenAIMessageType? type;
  final String? status;
  final OpenAIRole? role;
  final List<OpenAIOutputContent>? content;

  const OpenAIOutput({
    this.role,
    this.content,
    this.id,
    this.type,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        if (role != null) 'role': role!.value,
        if (content != null)
          'content': content!.map((c) => c.toJson()).toList(),
        if (id != null) 'id': id,
        if (type != null) 'type': type?.value,
        if (status != null) 'status': status,
      };

  factory OpenAIOutput.fromJson(Map<String, dynamic> json) {
    // 处理content字段可能为null的情况
    final contentList = json['content'] as List<dynamic>?;
    final roleValue = json['role'] as String?;

    return OpenAIOutput(
      role: roleValue != null
          ? OpenAIRole.values.firstWhere(
              (e) => e.value == roleValue,
              orElse: () => OpenAIRole.user,
            )
          : null,
      content: contentList?.map((e) {
        if (e is! Map<String, dynamic>) {
          throw Exception('OpenAIOutputContent数据类型错误: ${e.runtimeType}');
        }
        return OpenAIOutputContent.fromJson(e);
      }).toList(),
      id: json['id'] as String?,
      type: json['type'] == 'reasoning'
          ? OpenAIMessageType.reasoning
          : json['type'] == 'message'
              ? OpenAIMessageType.message
              : null,
      status: json['status'] as String?,
    );
  }

  String get displayContent =>
      content?.isNotEmpty == true ? (content!.first.text ?? '') : '';
}

/// OpenAI聊天完成响应
class OpenAIChatCompletion {
  final String? id;
  final String? object;
  final int? createdAt;
  final String? status;
  final bool? background;
  final String? model;
  final List<OpenAIOutput>? output;
  final OpenAIUsage? usage;
  final Map<String, dynamic>? billing;
  final dynamic error;
  final dynamic incompleteDetails;

  const OpenAIChatCompletion({
    this.id,
    this.object,
    this.createdAt,
    this.status,
    this.background,
    this.model,
    this.output,
    this.usage,
    this.billing,
    this.error,
    this.incompleteDetails,
  });

  factory OpenAIChatCompletion.fromJson(Map<String, dynamic> json) {
    // 处理output字段可能为null的情况
    final outputList = json['output'] as List<dynamic>?;
    final usageData = json['usage'] as Map<String, dynamic>?;

    return OpenAIChatCompletion(
      id: json['id'] as String?,
      object: json['object'] as String?,
      createdAt: json['created_at'] as int?,
      status: json['status'] as String?,
      background: json['background'] as bool?,
      model: json['model'] as String?,
      output: outputList?.map((e) {
        if (e is! Map<String, dynamic>) {
          throw Exception('OpenAIOutput数据类型错误: ${e.runtimeType}');
        }
        return OpenAIOutput.fromJson(e);
      }).toList(),
      usage: usageData != null ? OpenAIUsage.fromJson(usageData) : null,
      billing: json['billing'] as Map<String, dynamic>?,
      error: json['error'],
      incompleteDetails: json['incomplete_details'],
    );
  }
}

/// OpenAI使用量统计
class OpenAIUsage {
  final int? inputTokens;
  final int? outputTokens;
  final int? totalTokens;
  final Map<String, dynamic>? inputTokensDetails;
  final Map<String, dynamic>? outputTokensDetails;

  const OpenAIUsage({
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
    this.inputTokensDetails,
    this.outputTokensDetails,
  });

  factory OpenAIUsage.fromJson(Map<String, dynamic> json) {
    return OpenAIUsage(
      inputTokens: json['input_tokens'] as int?,
      outputTokens: json['output_tokens'] as int?,
      totalTokens: json['total_tokens'] as int?,
      inputTokensDetails: json['input_tokens_details'] as Map<String, dynamic>?,
      outputTokensDetails:
          json['output_tokens_details'] as Map<String, dynamic>?,
    );
  }

  /// 兼容旧API的属性
  int get promptTokens => inputTokens ?? 0;
  int get completionTokens => outputTokens ?? 0;
}

/// OpenAI Completion选项
class OpenAICompletionChoice {
  final String? text;
  final int? index;
  final String? finishReason;

  const OpenAICompletionChoice({this.text, this.index, this.finishReason});

  factory OpenAICompletionChoice.fromJson(Map<String, dynamic> json) {
    return OpenAICompletionChoice(
      text: json['text'] as String?,
      index: json['index'] as int?,
      finishReason: json['finish_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text,
        if (index != null) 'index': index,
        if (finishReason != null) 'finish_reason': finishReason,
      };
}

/// OpenAI Completion响应
class OpenAICompletion {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<OpenAICompletionChoice>? choices;
  final OpenAIUsage? usage;

  const OpenAICompletion({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
  });

  factory OpenAICompletion.fromJson(Map<String, dynamic> json) {
    final choicesList = json['choices'] as List<dynamic>?;
    final usageData = json['usage'] as Map<String, dynamic>?;

    return OpenAICompletion(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: json['created'] as int?,
      model: json['model'] as String?,
      choices: choicesList?.map((e) {
        if (e is! Map<String, dynamic>) {
          throw Exception('OpenAICompletionChoice数据类型错误: ${e.runtimeType}');
        }
        return OpenAICompletionChoice.fromJson(e);
      }).toList(),
      usage: usageData != null ? OpenAIUsage.fromJson(usageData) : null,
    );
  }

  String get text =>
      choices?.isNotEmpty == true ? (choices!.first.text ?? '') : '';
}

class OpenAIPrompt {
  final String? id;
  final Map<String, dynamic>? variables;
  final String? version;

  const OpenAIPrompt({this.id, this.variables, this.version});

  factory OpenAIPrompt.fromJson(Map<String, dynamic> json) {
    return OpenAIPrompt(
      id: json['id'] as String?,
      variables: json['variables'] as Map<String, dynamic>?,
      version: json['version'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (variables != null) 'variables': variables,
      if (version != null) 'version': version,
    };
  }
}

/// Chat Completion消息内容类型（支持文本和图片）
class OpenAIChatMessageContent {
  final String type; // "text" or "image_url"
  final String? text;
  final OpenAIImageUrl? imageUrl;

  const OpenAIChatMessageContent.text(this.text)
      : type = 'text',
        imageUrl = null;

  const OpenAIChatMessageContent.image(this.imageUrl)
      : type = 'image_url',
        text = null;

  factory OpenAIChatMessageContent.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    if (type == 'text') {
      return OpenAIChatMessageContent.text(json['text'] as String?);
    } else if (type == 'image_url') {
      final imageUrlData = json['image_url'] as Map<String, dynamic>?;
      return OpenAIChatMessageContent.image(
        imageUrlData != null ? OpenAIImageUrl.fromJson(imageUrlData) : null,
      );
    }
    throw Exception('Unknown content type: $type');
  }

  Map<String, dynamic> toJson() {
    if (type == 'text') {
      return {'type': 'text', 'text': text};
    } else {
      return {'type': 'image_url', 'image_url': imageUrl?.toJson()};
    }
  }
}

/// 图片URL模型（支持普通URL和base64）
class OpenAIImageUrl {
  final String url;
  final String? detail; // "auto", "low", "high"

  const OpenAIImageUrl({
    required this.url,
    this.detail,
  });

  factory OpenAIImageUrl.fromJson(Map<String, dynamic> json) {
    return OpenAIImageUrl(
      url: json['url'] as String,
      detail: json['detail'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        if (detail != null) 'detail': detail,
      };
}

/// Chat Completion消息模型（标准OpenAI格式，支持多模态）
class OpenAIChatMessage {
  final OpenAIRole role;
  final dynamic content; // String or List<OpenAIChatMessageContent>

  const OpenAIChatMessage({
    required this.role,
    required this.content,
  });

  /// 创建纯文本消息
  factory OpenAIChatMessage.text({
    required OpenAIRole role,
    required String content,
  }) {
    return OpenAIChatMessage(role: role, content: content);
  }

  /// 创建多模态消息（文本+图片）
  factory OpenAIChatMessage.multimodal({
    required OpenAIRole role,
    required List<OpenAIChatMessageContent> content,
  }) {
    return OpenAIChatMessage(role: role, content: content);
  }

  factory OpenAIChatMessage.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'] as String;
    final role = OpenAIRole.values.firstWhere(
      (e) => e.value == roleValue,
      orElse: () => OpenAIRole.user,
    );

    final contentData = json['content'];
    dynamic content;
    if (contentData is String) {
      content = contentData;
    } else if (contentData is List) {
      content = (contentData)
          .map((e) =>
              OpenAIChatMessageContent.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      content = '';
    }

    return OpenAIChatMessage(role: role, content: content);
  }

  Map<String, dynamic> toJson() {
    dynamic contentJson;
    if (content is String) {
      contentJson = content;
    } else if (content is List<OpenAIChatMessageContent>) {
      contentJson = (content as List<OpenAIChatMessageContent>)
          .map((c) => c.toJson())
          .toList();
    }

    return {
      'role': role.value,
      'content': contentJson,
    };
  }

  /// 获取文本内容（兼容方法）
  String get textContent {
    if (content is String) {
      return content as String;
    } else if (content is List<OpenAIChatMessageContent>) {
      final textContent = (content as List<OpenAIChatMessageContent>)
          .where((c) => c.type == 'text')
          .map((c) => c.text ?? '')
          .join(' ');
      return textContent;
    }
    return '';
  }
}

/// Chat Completion选择项（标准OpenAI格式）
class OpenAIChatChoice {
  final int index;
  final OpenAIChatMessage message;
  final String? finishReason;

  const OpenAIChatChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory OpenAIChatChoice.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>?;
    return OpenAIChatChoice(
      index: json['index'] as int? ?? 0,
      message: messageData != null
          ? OpenAIChatMessage.fromJson(messageData)
          : const OpenAIChatMessage(role: OpenAIRole.assistant, content: ''),
      finishReason: json['finish_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'message': message.toJson(),
        if (finishReason != null) 'finish_reason': finishReason,
      };
}

/// Chat Completion响应（标准OpenAI格式）
class OpenAIChatCompletionResponse {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<OpenAIChatChoice>? choices;
  final OpenAIUsage? usage;

  const OpenAIChatCompletionResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    this.choices,
    this.usage,
  });

  factory OpenAIChatCompletionResponse.fromJson(Map<String, dynamic> json) {
    final choicesList = json['choices'] as List<dynamic>?;
    final usageData = json['usage'] as Map<String, dynamic>?;

    return OpenAIChatCompletionResponse(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: json['created'] as int?,
      model: json['model'] as String?,
      choices: choicesList?.map((e) {
        if (e is! Map<String, dynamic>) {
          throw Exception('OpenAIChatChoice数据类型错误: ${e.runtimeType}');
        }
        return OpenAIChatChoice.fromJson(e);
      }).toList(),
      usage: usageData != null ? OpenAIUsage.fromJson(usageData) : null,
    );
  }

  /// 获取第一个choice的消息内容
  String get messageContent =>
      choices?.isNotEmpty == true ? choices!.first.message.content : '';
}
