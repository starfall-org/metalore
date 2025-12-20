part of 'chat_viewmodel.dart';

extension ChatViewModelMessageActions on ChatViewModel {
  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && pendingAttachments.isEmpty) ||
        currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(pendingAttachments);
    textController.clear();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    currentSession = currentSession!.copyWith(
      messages: [...currentSession!.messages, userMessage],
      updatedAt: DateTime.now(),
    );
    isGenerating = true;
    pendingAttachments.clear();
    notify();

    if (currentSession!.messages.length == 1) {
      final base = text.isNotEmpty
          ? text
          : (attachments.isNotEmpty
                ? 'attachments.title_count'.tr(
                    namedArgs: {'count': attachments.length.toString()},
                  )
                : 'drawer.new_chat'.tr());
      final title = base.length > 30 ? '${base.substring(0, 30)}...' : base;
      currentSession = currentSession!.copyWith(title: title);
    }

    await chatRepository!.saveConversation(currentSession!);
    scrollToBottom();

    String modelInput = text;
    if (attachments.isNotEmpty) {
      final names = attachments.map((p) => p.split('/').last).join(', ');
      modelInput =
          '${modelInput.isEmpty ? '' : '$modelInput\n'}[Attachments: $names]';
    }

    // Select provider/model based on preferences
    final providerRepo = await ProviderRepository.init();
    final providersList = providerRepo.getProviders();

    final persist = shouldPersistSelections();
    String providerName;
    String modelName;

    if (persist &&
        currentSession?.providerName != null &&
        currentSession?.modelName != null) {
      providerName = currentSession!.providerName!;
      modelName = currentSession!.modelName!;
    } else {
      providerName =
          selectedProviderName ??
          (providersList.isNotEmpty ? providersList.first.name : '');
      modelName =
          selectedModelName ??
          ((providersList.isNotEmpty && providersList.first.models.isNotEmpty)
              ? providersList.first.models.first.name
              : '');
      // If persistence is enabled, store selection on the conversation
      if (currentSession != null && persist) {
        currentSession = currentSession!.copyWith(
          providerName: providerName,
          modelName: modelName,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
    }

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        // Snapshot currently enabled MCP tools from agent for this conversation
        final agent =
            selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            );
        final names = await _snapshotEnabledToolNames(agent);
        currentSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final doStream = selectedAgent?.config.enableStream ?? true;
    if (doStream) {
      final stream = ChatService.generateStream(
        userText: modelInput,
        history: currentSession!.messages
            .take(currentSession!.messages.length - 1)
            .toList(),
        agent:
            selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelId = const Uuid().v4();
      var acc = '';
      final placeholder = ChatMessage(
        id: modelId,
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      );

      currentSession = currentSession!.copyWith(
        messages: [...currentSession!.messages, placeholder],
        updatedAt: DateTime.now(),
      );
      notify();

      try {
        await for (final chunk in stream) {
          if (chunk.isEmpty) continue;
          acc += chunk;
          final msgs = List<ChatMessage>.from(currentSession!.messages);
          final idx = msgs.indexWhere((m) => m.id == modelId);
          if (idx != -1) {
            final old = msgs[idx];
            msgs[idx] = ChatMessage(
              id: old.id,
              role: old.role,
              content: acc,
              timestamp: old.timestamp,
              attachments: old.attachments,
              reasoningContent: old.reasoningContent,
              aiMedia: old.aiMedia,
            );
            currentSession = currentSession!.copyWith(
              messages: msgs,
              updatedAt: DateTime.now(),
            );
            notify();
            scrollToBottom();
          }
        }
      } finally {
        isGenerating = false;
        notify();
        await chatRepository!.saveConversation(currentSession!);
      }
    } else {
      final reply = await ChatService.generateReply(
        userText: modelInput,
        history: currentSession!.messages
            .take(currentSession!.messages.length - 1)
            .toList(),
        agent:
            selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelMessage = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.model,
        content: reply,
        timestamp: DateTime.now(),
      );

      currentSession = currentSession!.copyWith(
        messages: [...currentSession!.messages, modelMessage],
        updatedAt: DateTime.now(),
      );
      isGenerating = false;
      notify();

      await chatRepository!.saveConversation(currentSession!);
      scrollToBottom();
    }
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (currentSession == null || currentSession!.messages.isEmpty) return;

    final msgs = currentSession!.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }
    if (lastUserIndex == -1) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('chat.no_user_to_regen'.tr())));
      }
      return;
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    isGenerating = true;
    notify();

    final providerRepo = await ProviderRepository.init();
    final providersList = providerRepo.getProviders();

    final persist = shouldPersistSelections();
    String providerName;
    String modelName;

    if (persist &&
        currentSession?.providerName != null &&
        currentSession?.modelName != null) {
      providerName = currentSession!.providerName!;
      modelName = currentSession!.modelName!;
    } else {
      providerName =
          selectedProviderName ??
          (providersList.isNotEmpty ? providersList.first.name : '');
      modelName =
          selectedModelName ??
          ((providersList.isNotEmpty && providersList.first.models.isNotEmpty)
              ? providersList.first.models.first.name
              : '');
      if (currentSession != null && persist) {
        currentSession = currentSession!.copyWith(
          providerName: providerName,
          modelName: modelName,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
    }

    List<String>? allowedToolNames;
    if (persist) {
      if (currentSession!.enabledToolNames == null) {
        final agent =
            selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            );
        final names = await _snapshotEnabledToolNames(agent);
        currentSession = currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await chatRepository!.saveConversation(currentSession!);
      }
      allowedToolNames = currentSession!.enabledToolNames;
    }

    final doStream = selectedAgent?.config.enableStream ?? true;
    if (doStream) {
      final stream = ChatService.generateStream(
        userText: userText,
        history: history,
        agent:
            selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelId = const Uuid().v4();
      var acc = '';
      final placeholder = ChatMessage(
        id: modelId,
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      );

      final baseMessages = [...history, msgs[lastUserIndex]];
      currentSession = currentSession!.copyWith(
        messages: [...baseMessages, placeholder],
        updatedAt: DateTime.now(),
      );
      notify();

      try {
        await for (final chunk in stream) {
          if (chunk.isEmpty) continue;
          acc += chunk;
          final msgs2 = List<ChatMessage>.from(currentSession!.messages);
          final idx = msgs2.indexWhere((m) => m.id == modelId);
          if (idx != -1) {
            final old = msgs2[idx];
            msgs2[idx] = ChatMessage(
              id: old.id,
              role: old.role,
              content: acc,
              timestamp: old.timestamp,
              attachments: old.attachments,
              reasoningContent: old.reasoningContent,
              aiMedia: old.aiMedia,
            );
            currentSession = currentSession!.copyWith(
              messages: msgs2,
              updatedAt: DateTime.now(),
            );
            notify();
            scrollToBottom();
          }
        }
      } finally {
        isGenerating = false;
        notify();
        await chatRepository!.saveConversation(currentSession!);
      }
    } else {
      final reply = await ChatService.generateReply(
        userText: userText,
        history: history,
        agent:
            selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              config: RequestConfig(systemPrompt: '', enableStream: true),
            ),
        providerName: providerName,
        modelName: modelName,
        allowedToolNames: allowedToolNames,
      );

      final modelMessage = ChatMessage(
        id: const Uuid().v4(),
        role: ChatRole.model,
        content: reply,
        timestamp: DateTime.now(),
      );

      final newMessages = [...history, msgs[lastUserIndex], modelMessage];

      currentSession = currentSession!.copyWith(
        messages: newMessages,
        updatedAt: DateTime.now(),
      );
      isGenerating = false;
      notify();

      await chatRepository!.saveConversation(currentSession!);
      scrollToBottom();
    }
  }
}
