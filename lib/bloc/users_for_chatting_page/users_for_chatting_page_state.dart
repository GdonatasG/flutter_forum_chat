abstract class UsersForChattingPageState {
  const UsersForChattingPageState();
}

class UsersForChattingPageInitial extends UsersForChattingPageState {
  const UsersForChattingPageInitial();

  List<Object> get props => [];
}

class NoInternet extends UsersForChattingPageState {
  final String error;

  NoInternet(this.error);

  List<Object> get props => [this.error];
}

class ChatAlreadyExists extends UsersForChattingPageState {
  final String chatId;

  ChatAlreadyExists(this.chatId);

  List<Object> get props => [this.chatId];
}

class ChatSuccessfullyCreated extends UsersForChattingPageState {
  final String chatId;

  ChatSuccessfullyCreated(this.chatId);

  List<Object> get props => [this.chatId];
}

class ChatCreatingError extends UsersForChattingPageState {
  final String error;

  ChatCreatingError(this.error);

  List<Object> get props => [this.error];
}
