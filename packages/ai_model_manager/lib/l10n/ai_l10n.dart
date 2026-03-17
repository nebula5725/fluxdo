import 'dart:ui';

/// AI 模型管理包的本地化代理
/// 由主项目在启动时通过 configureLocale 配置语言
class AiL10n {
  static AiL10n? _instance;

  static AiL10n get current => _instance ?? _defaultInstance;

  /// 根据 Locale 配置语言
  static void configureLocale(Locale locale) {
    if (locale.languageCode == 'en') {
      _instance = AiL10nEn();
    } else {
      _instance = _defaultInstance;
    }
  }

  /// 直接注入自定义实例
  static void configure(AiL10n instance) {
    _instance = instance;
  }

  // 默认中文实例
  static final _defaultInstance = AiL10n();

  // ---- 通用 ----
  String get cancel => '取消';
  String get delete => '删除';
  String get save => '保存';
  String get add => '添加';
  String get edit => '编辑';
  String get remove => '移除';
  String get test => '测试';
  String get notSet => '未设置';
  String get name => '名称';
  String get import_ => '导入';

  // ---- AI 模型服务页 ----
  String get aiModelService => 'AI 模型服务';
  String get addProvider => '添加供应商';
  String get editProvider => '编辑供应商';
  String get noProviderConfigured => '还没有配置 AI 供应商';
  String get addProviderHint => '添加供应商后可以使用 AI 助手功能';
  String get confirmDelete => '确认删除';
  String confirmDeleteProvider(String name) => '确定要删除供应商「$name」吗？';
  String modelCount(int enabled, int total) => '$enabled/$total 个模型';
  String get chatHistory => '聊天记录';
  String get titleGenerationModel => '标题生成模型';
  String get autoGenerateTitleSubtitle => '自动为新会话生成标题';
  String get noAutoGenerateTitle => '不自动生成标题';
  String get maxSessionCount => '最大会话记录数';
  String get autoDeleteOldestSession => '超出上限时自动删除最旧的会话';
  String get sessionManagement => '会话记录管理';
  String totalSessionCount(int count) => '共 $count 条会话';

  // ---- 供应商编辑页 ----
  String get pleaseEnterBaseUrlAndApiKey => '请填写 Base URL 和 API Key';
  String get connectionSuccess => '连接成功';
  String get connectionFailed => '连接失败';
  String connectionFailedWithError(String error) => '连接失败: $error';
  String fetchedModelsCount(int count) => '获取到 $count 个模型';
  String fetchModelsFailed(String error) => '获取模型失败: $error';
  String get addModelManually => '手动添加模型';
  String get modelId => '模型 ID';
  String get modelIdHint => '例如: gpt-4o';
  String get pleaseEnterProviderName => '请输入供应商名称';
  String get pleaseEnterBaseUrl => '请输入 Base URL';
  String get pleaseEnterApiKey => '请输入 API Key';
  String get pleaseEnterBaseUrlAndApiKeyFirst => '请先填写 Base URL 和 API Key';
  String saveFailed(String error) => '保存失败: $error';
  String get defaultModelCleared => '已取消默认模型';
  String get setAsDefaultModel => '已设为默认模型';
  String modelAvailable(String id) => '模型 $id 可用';
  String modelUnavailable(String id, String error) => '模型 $id 不可用: $error';
  String get basicConfig => '基础配置';
  String get nameHint => '例如: 我的 OpenAI';
  String get providerType => '供应商类型';
  String get connectivityCheck => '连通性检查';
  String get modelManagement => '模型管理';
  String get fetchModels => '获取模型';
  String get manuallyAdd => '手动添加';
  String get cancelDefault => '取消默认';
  String get setAsDefault => '设为默认';

  // ---- 聊天历史页 ----
  String get sessionHistory => '会话记录';
  String get clearAllConversations => '清除所有对话';
  String get noSessionHistory => '暂无会话记录';
  String confirmDeleteAllSessions(int count) =>
      '确定要删除全部 $count 条会话记录吗？此操作不可恢复。';
  String get clearAll => '清除全部';
  String topicWithId(int id) => '话题 #$id';
  String sessionCount(int count) => '$count 条会话';
  String get deleteAllTopicSessions => '删除此话题所有会话';
  String get unnamedSession => '未命名会话';
  String get deleteTopicSessions => '删除话题会话';
  String confirmDeleteTopicSessions(String title) =>
      '确定要删除「$title」的所有会话记录吗？';
  String get justNow => '刚刚';
  String minutesAgo(int count) => '$count 分钟前';
  String hoursAgo(int count) => '$count 小时前';
  String daysAgo(int count) => '$count 天前';

  // ---- 上下文选项 ----
  String get firstPostOnly => '仅主帖';
  String get first5Posts => '前 5 楼';
  String get first10Posts => '前 10 楼';
  String get first20Posts => '前 20 楼';
  String get allPosts => '全部帖子';

  // ---- 网络错误 ----
  String get connectionTimeoutError => '连接超时，请检查网络或 Base URL 是否正确';
  String get cannotConnectError => '无法连接到服务器，请检查 Base URL 是否正确';
  String get apiKeyInvalidError => 'API Key 无效或已过期 (401)';
  String get noAccessPermissionError => '没有访问权限，请检查 API Key (403)';
  String get endpointNotFoundError => '接口地址不存在，请检查 Base URL (404)';
  String get tooManyRequestsError => '请求过于频繁，请稍后重试 (429)';
  String serverInternalError(int code) => '服务器内部错误 ($code)';
  String requestFailed(int code) => '请求失败 ($code)';
  String get requestCancelled => '请求已取消';
  String get sslCertificateError => 'SSL 证书验证失败';
  String get networkConnectionFailed => '网络连接失败，请检查网络设置';
  String get unknownNetworkError => '未知网络错误';

  // ---- System Prompts（影响 AI 回复语言） ----
  String get systemPromptIntro =>
      '你是一个有帮助的 AI 助手，正在帮助用户理解和讨论一个论坛话题。';
  String systemPromptTopicTitle(String title) => '话题标题：$title';
  String get systemPromptContextHint =>
      '用户可能会就话题内容向你提问，请基于提供的上下文回答。';
  String get systemPromptMarkdown => '请用 Markdown 格式回复。';
  String contextContentPrefix(String text) => '以下是话题内容：\n$text';
  String get contextReadyResponse => '好的，我已经阅读了话题内容。请问你有什么问题？';
  String get titleGenerationPrompt =>
      '请用不超过15个字概括用户这段话的主题，直接输出标题文字，不要加标点符号和引号。';
}

/// 英文翻译
class AiL10nEn extends AiL10n {
  // ---- 通用 ----
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get save => 'Save';
  @override
  String get add => 'Add';
  @override
  String get edit => 'Edit';
  @override
  String get remove => 'Remove';
  @override
  String get test => 'Test';
  @override
  String get notSet => 'Not set';
  @override
  String get name => 'Name';
  @override
  String get import_ => 'Import';

  // ---- AI 模型服务页 ----
  @override
  String get aiModelService => 'AI Model Service';
  @override
  String get addProvider => 'Add Provider';
  @override
  String get editProvider => 'Edit Provider';
  @override
  String get noProviderConfigured => 'No AI provider configured';
  @override
  String get addProviderHint =>
      'Add a provider to use the AI assistant feature';
  @override
  String get confirmDelete => 'Confirm Delete';
  @override
  String confirmDeleteProvider(String name) =>
      'Are you sure you want to delete provider "$name"?';
  @override
  String modelCount(int enabled, int total) => '$enabled/$total models';
  @override
  String get chatHistory => 'Chat History';
  @override
  String get titleGenerationModel => 'Title Generation Model';
  @override
  String get autoGenerateTitleSubtitle =>
      'Auto-generate titles for new sessions';
  @override
  String get noAutoGenerateTitle => 'Do not auto-generate titles';
  @override
  String get maxSessionCount => 'Max Session Count';
  @override
  String get autoDeleteOldestSession =>
      'Auto-delete oldest session when limit is exceeded';
  @override
  String get sessionManagement => 'Session Management';
  @override
  String totalSessionCount(int count) => '$count sessions total';

  // ---- 供应商编辑页 ----
  @override
  String get pleaseEnterBaseUrlAndApiKey =>
      'Please enter Base URL and API Key';
  @override
  String get connectionSuccess => 'Connection successful';
  @override
  String get connectionFailed => 'Connection failed';
  @override
  String connectionFailedWithError(String error) =>
      'Connection failed: $error';
  @override
  String fetchedModelsCount(int count) => 'Fetched $count models';
  @override
  String fetchModelsFailed(String error) => 'Failed to fetch models: $error';
  @override
  String get addModelManually => 'Add Model Manually';
  @override
  String get modelId => 'Model ID';
  @override
  String get modelIdHint => 'e.g. gpt-4o';
  @override
  String get pleaseEnterProviderName => 'Please enter provider name';
  @override
  String get pleaseEnterBaseUrl => 'Please enter Base URL';
  @override
  String get pleaseEnterApiKey => 'Please enter API Key';
  @override
  String get pleaseEnterBaseUrlAndApiKeyFirst =>
      'Please enter Base URL and API Key first';
  @override
  String saveFailed(String error) => 'Save failed: $error';
  @override
  String get defaultModelCleared => 'Default model cleared';
  @override
  String get setAsDefaultModel => 'Set as default model';
  @override
  String modelAvailable(String id) => 'Model $id is available';
  @override
  String modelUnavailable(String id, String error) =>
      'Model $id unavailable: $error';
  @override
  String get basicConfig => 'Basic Configuration';
  @override
  String get nameHint => 'e.g. My OpenAI';
  @override
  String get providerType => 'Provider Type';
  @override
  String get connectivityCheck => 'Connectivity Check';
  @override
  String get modelManagement => 'Model Management';
  @override
  String get fetchModels => 'Fetch Models';
  @override
  String get manuallyAdd => 'Add Manually';
  @override
  String get cancelDefault => 'Unset Default';
  @override
  String get setAsDefault => 'Set Default';

  // ---- 聊天历史页 ----
  @override
  String get sessionHistory => 'Session History';
  @override
  String get clearAllConversations => 'Clear all conversations';
  @override
  String get noSessionHistory => 'No session history';
  @override
  String confirmDeleteAllSessions(int count) =>
      'Are you sure you want to delete all $count sessions? This action cannot be undone.';
  @override
  String get clearAll => 'Clear All';
  @override
  String topicWithId(int id) => 'Topic #$id';
  @override
  String sessionCount(int count) => '$count sessions';
  @override
  String get deleteAllTopicSessions => 'Delete all sessions for this topic';
  @override
  String get unnamedSession => 'Unnamed session';
  @override
  String get deleteTopicSessions => 'Delete Topic Sessions';
  @override
  String confirmDeleteTopicSessions(String title) =>
      'Are you sure you want to delete all sessions for "$title"?';
  @override
  String get justNow => 'Just now';
  @override
  String minutesAgo(int count) => '$count min ago';
  @override
  String hoursAgo(int count) => '$count hr ago';
  @override
  String daysAgo(int count) => '$count days ago';

  // ---- 上下文选项 ----
  @override
  String get firstPostOnly => 'First post only';
  @override
  String get first5Posts => 'First 5 posts';
  @override
  String get first10Posts => 'First 10 posts';
  @override
  String get first20Posts => 'First 20 posts';
  @override
  String get allPosts => 'All posts';

  // ---- 网络错误 ----
  @override
  String get connectionTimeoutError =>
      'Connection timed out. Please check your network or Base URL';
  @override
  String get cannotConnectError =>
      'Cannot connect to server. Please check your Base URL';
  @override
  String get apiKeyInvalidError => 'API Key is invalid or expired (401)';
  @override
  String get noAccessPermissionError =>
      'No access permission. Please check your API Key (403)';
  @override
  String get endpointNotFoundError =>
      'Endpoint not found. Please check your Base URL (404)';
  @override
  String get tooManyRequestsError =>
      'Too many requests. Please try again later (429)';
  @override
  String serverInternalError(int code) => 'Server internal error ($code)';
  @override
  String requestFailed(int code) => 'Request failed ($code)';
  @override
  String get requestCancelled => 'Request cancelled';
  @override
  String get sslCertificateError => 'SSL certificate verification failed';
  @override
  String get networkConnectionFailed =>
      'Network connection failed. Please check your network settings';
  @override
  String get unknownNetworkError => 'Unknown network error';

  // ---- System Prompts ----
  @override
  String get systemPromptIntro =>
      'You are a helpful AI assistant helping the user understand and discuss a forum topic.';
  @override
  String systemPromptTopicTitle(String title) => 'Topic title: $title';
  @override
  String get systemPromptContextHint =>
      'The user may ask you questions about the topic content. Please answer based on the provided context.';
  @override
  String get systemPromptMarkdown => 'Please respond in Markdown format.';
  @override
  String contextContentPrefix(String text) =>
      'Here is the topic content:\n$text';
  @override
  String get contextReadyResponse =>
      'OK, I have read the topic content. What questions do you have?';
  @override
  String get titleGenerationPrompt =>
      'Summarize the topic of this text in no more than 10 words. Output the title text directly without punctuation or quotes.';
}
