import '../models/openai_models.dart';
import 'i_cancel_token.dart';
import 'i_http_client.dart';

/// OpenAI客户端接口
abstract class IOpenAIClient {
  /// Chat Response API（支持输入列表）
  Future<ApiResponse<OpenAIChatCompletion>> chatResponse({
    required OpenAIModel model,
    required List<OpenAIInput> inputs,
    int? maxTokens,
    double? topP,
    int? n,
    List<String>? stop,
    double? presencePenalty,
    double? frequencyPenalty,
    String? user,
    OpenAIReasoning? reasoning,
    OpenAIPrompt? prompt,
    String? promptCacheKey,
  });

  /// 简单的聊天方法
  Future<ApiResponse<String>> simpleChat({
    String? message,
    String? customPrompt,
    List<OpenAIChatMessage>? messageHistory,
    OpenAIModel model,
    int? maxTokens,
    ICancelToken? cancelToken,
  });

  /// Chat Completion API（标准OpenAI格式）
  Future<ApiResponse<OpenAIChatCompletionResponse>> chatCompletion({
    required OpenAIModel model,
    required List<OpenAIChatMessage> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? n,
    bool? stream,
    List<String>? stop,
    double? presencePenalty,
    double? frequencyPenalty,
    String? user,
    int? seed,
    int? topK,
    Map<String, double>? logitBias,
    int? topLogprobs,
    double? minP,
    double? topA,
    OpenAIReasoning reasoning,
    ICancelToken? cancelToken,
  });

  /// OCR图片识别
  Future<ApiResponse<String>> ocrImage({
    required List<String> base64Images,
    String mimeType,
    required String customPrompt,
    OpenAIModel model,
    int? maxTokens,
    ICancelToken? cancelToken,
  });
}
