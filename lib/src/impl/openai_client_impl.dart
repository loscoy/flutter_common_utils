import 'package:dio/dio.dart';
import '../abstraction/i_app_logger.dart';
import '../abstraction/i_device_info_service.dart';
import '../abstraction/i_http_client.dart';
import '../abstraction/i_openai_client.dart';
import '../models/openai_models.dart';

/// OpenAI API客户端实现
class OpenAIClientImpl implements IOpenAIClient {
  final IDeviceInfoService _deviceInfoService;
  final IHttpClient _httpClient;
  final IAppLogger _logger;
  final String baseUrl;

  String _deviceId = '';

  OpenAIClientImpl({
    required this.baseUrl,
    required IDeviceInfoService deviceInfoService,
    required IHttpClient httpClient,
    required IAppLogger logger,
  })  : _deviceInfoService = deviceInfoService,
        _httpClient = httpClient,
        _logger = logger;

  /// 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    if (_deviceId.isEmpty) {
      _deviceId = await _deviceInfoService.getDeviceId();
    }
    return {
      'Content-Type': 'application/json',
      'd': _deviceId,
      'X-Haibara-Ai-Warning': 'APTX-4869',
    };
  }

  @override
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
    OpenAIReasoning? reasoning = const OpenAIReasoning(
      effort: OpenAIReasoningEffort.minimal,
    ),
    OpenAIPrompt? prompt,
    String? promptCacheKey,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model.value,
        'input': inputs.map((m) => m.toJson()).toList(),
        if (maxTokens != null) 'max_output_tokens': maxTokens,
        if (topP != null) 'top_p': topP,
        if (n != null) 'n': n,
        if (stop != null) 'stop': stop,
        if (presencePenalty != null) 'presence_penalty': presencePenalty,
        if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
        if (user != null) 'user': user,
        if (reasoning != null) 'reasoning': reasoning.toJson(),
        if (prompt != null) 'prompt': prompt.toJson(),
        if (promptCacheKey != null) 'prompt_cache_key': promptCacheKey,
      };

      final response = await _httpClient.postWithBaseUrl<OpenAIChatCompletion>(
        baseUrl: baseUrl,
        path: '/responses',
        data: requestData,
        headers: await _getHeaders(),
        converter: (data) {
          if (data == null) {
            throw Exception('Response data is null');
          }
          if (data is! Map<String, dynamic>) {
            throw Exception(
              'OpenAI API returned data is not Map<String, dynamic>, but: ${data.runtimeType}',
            );
          }
          return OpenAIChatCompletion.fromJson(data);
        },
      );

      if (response.isSuccess) {
        _logger.i(
          '✅ OpenAI Chat completion successful - tokens: ${response.data?.usage?.totalTokens ?? 0}',
        );
      } else {
        _logger.e(
          '❌ OpenAI Chat completion failed: ${response.message}, ${response.data}',
        );
      }

      return response;
    } catch (e) {
      _logger.e('❌ OpenAI Chat completion error: $e');
      return ApiResponse.error(message: 'OpenAI request failed: $e', error: e);
    }
  }

  @override
  Future<ApiResponse<String>> simpleChat({
    String? message,
    String? customPrompt,
    List<OpenAIChatMessage>? messageHistory,
    OpenAIModel model = OpenAIModel.gpt5,
    int? maxTokens,
    CancelToken? cancelToken,
  }) async {
    final messages = <OpenAIChatMessage>[
      if (customPrompt != null)
        OpenAIChatMessage(role: OpenAIRole.system, content: customPrompt),
      if (messageHistory != null) ...messageHistory,
      if (message != null)
        OpenAIChatMessage(role: OpenAIRole.user, content: message),
    ];

    final response = await chatCompletion(
      model: model,
      messages: messages,
      maxTokens: maxTokens,
      cancelToken: cancelToken,
    );

    if (response.isSuccess && response.data != null) {
      final text = response.data!.messageContent;
      return ApiResponse.success(
        data: text,
        message: 'Chat completion successful',
        statusCode: response.statusCode,
      );
    }

    return ApiResponse.error(
      message: response.message ?? 'Chat completion failed',
      statusCode: response.statusCode,
      error: response.error,
    );
  }

  @override
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
    OpenAIReasoning reasoning = const OpenAIReasoning(
      effort: OpenAIReasoningEffort.minimal,
    ),
    CancelToken? cancelToken,
  }) async {
    try {
      final requestData = <String, dynamic>{
        'model': model.value,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (maxTokens != null) 'max_tokens': maxTokens,
        if (temperature != null) 'temperature': temperature,
        if (topP != null) 'top_p': topP,
        if (n != null) 'n': n,
        if (stream != null) 'stream': stream,
        if (stop != null) 'stop': stop,
        if (presencePenalty != null) 'presence_penalty': presencePenalty,
        if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
        if (user != null) 'user': user,
        if (seed != null) 'seed': seed,
        if (topK != null) 'top_k': topK,
        if (logitBias != null) 'logit_bias': logitBias,
        if (topLogprobs != null) 'top_logprobs': topLogprobs,
        if (minP != null) 'min_p': minP,
        if (topA != null) 'top_a': topA,
        'reasoning': reasoning.toJson(),
      };

      final response =
          await _httpClient.postWithBaseUrl<OpenAIChatCompletionResponse>(
        baseUrl: baseUrl,
        path: '/chat/completions',
        data: requestData,
        headers: await _getHeaders(),
        cancelToken: cancelToken,
        converter: (data) {
          if (data == null) {
            throw Exception('Response data is null');
          }
          if (data is! Map<String, dynamic>) {
            throw Exception(
              'Chat Completion API returned data is not Map<String, dynamic>, but: ${data.runtimeType}',
            );
          }
          return OpenAIChatCompletionResponse.fromJson(data);
        },
      );

      if (response.isSuccess) {
        _logger.i(
          '✅ Chat Completion successful - tokens: ${response.data?.usage?.totalTokens ?? 0}',
        );
      } else {
        _logger.e(
          '❌ Chat Completion failed: ${response.message}, ${response.data}',
        );
      }

      return response;
    } catch (e) {
      _logger.e('❌ Chat Completion error: $e');
      return ApiResponse.error(
        message: 'Chat Completion request failed: $e',
        error: e,
      );
    }
  }

  @override
  Future<ApiResponse<String>> ocrImage({
    required List<String> base64Images,
    required String customPrompt,
    String mimeType = 'image/jpeg',
    OpenAIModel model = OpenAIModel.gpt5,
    int? maxTokens,
    CancelToken? cancelToken,
  }) async {
    try {
      // 构建多模态消息内容列表
      final contentList = <OpenAIChatMessageContent>[
        OpenAIChatMessageContent.text(customPrompt),
        ...base64Images.map((base64Image) {
          final imageDataUrl = 'data:$mimeType;base64,$base64Image';
          return OpenAIChatMessageContent.image(
            OpenAIImageUrl(url: imageDataUrl),
          );
        }),
      ];

      final message = OpenAIChatMessage.multimodal(
        role: OpenAIRole.user,
        content: contentList,
      );

      final response = await chatCompletion(
        model: model,
        messages: [message],
        maxTokens: maxTokens ?? 2000,
        cancelToken: cancelToken,
      );

      if (response.isSuccess && response.data != null) {
        final jsonResult = response.data!.messageContent;
        _logger.i(
            '✅ OCR successful - extracted JSON length: ${jsonResult.length}');

        return ApiResponse.success(
          data: jsonResult,
          message: 'OCR extraction successful',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(
        message: response.message ?? 'OCR extraction failed',
        statusCode: response.statusCode,
        error: response.error,
      );
    } catch (e, stackTrace) {
      _logger.e('❌ OCR error: $e', e, stackTrace);
      return ApiResponse.error(
        message: 'OCR request failed: $e',
        error: e,
      );
    }
  }
}
