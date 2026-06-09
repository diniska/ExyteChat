//
//  SwiftUIView.swift
//
//
//  Created by Alisa Mylnikova on 06.12.2023.
//

import SwiftUI

public extension ChatView {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         inputViewBuilder: @escaping InputViewBuilderClosure,
         messageMenuAction: MessageMenuActionClosure?
    ) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            inputViewBuilder: inputViewBuilder,
            messageMenuAction: messageMenuAction
        )
    }
}

public extension ChatView where InputViewContent == EmptyView {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageBuilder: @escaping MessageBuilderClosure,
         messageMenuAction: MessageMenuActionClosure?) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            messageBuilder: messageBuilder,
            messageMenuAction: messageMenuAction
        )
    }
}

public extension ChatView where MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageBuilder: @escaping MessageBuilderClosure,
         inputViewBuilder: @escaping InputViewBuilderClosure) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            messageBuilder: messageBuilder,
            inputViewBuilder: inputViewBuilder
        )
    }
}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageMenuAction: MessageMenuActionClosure?) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            messageMenuAction: messageMenuAction,
            localization: Self.createLocalization()
        )
    }
}

public extension ChatView where InputViewContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageBuilder: @escaping MessageBuilderClosure) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            messageBuilder: messageBuilder,
            localization: Self.createLocalization()
        )
    }
}

public extension ChatView where MessageContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         inputViewBuilder: @escaping InputViewBuilderClosure) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            inputViewBuilder: inputViewBuilder,
            localization: Self.createLocalization()
        )
    }
}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil) {
        self.init(
            messages: messages,
            chatType: chatType,
            replyMode: replyMode,
            didSendMessage: didSendMessage,
            reactionDelegate: reactionDelegate,
            localization: Self.createLocalization()
        )
    }
}
