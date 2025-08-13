# Quirinom Chat

A Flutter chat application with customer and vendor login functionality, built using BLoC state management and MVVM architecture.

## Features

- **Dual User Types**: Support for both Customer and Vendor login
- **Real-time Chat**: Socket.IO integration for instant messaging
- **Chat History**: View and manage conversation history
- **Modern UI**: Beautiful and responsive Material Design interface
- **State Management**: BLoC pattern for efficient state management
- **MVVM Architecture**: Clean separation of concerns

## API Endpoints

- **Base URL**: `http://45.129.87.38:6065`
- **Login**: `POST /user/login`
- **Get User Chats**: `GET /chats/user-chats/:userId`
- **Get Chat Messages**: `GET /messages/get-messagesformobile/:chatId`
- **Send Message**: `POST /messages/sendMessage`

## Demo Credentials

- **Email**: swaroop.vass@gmail.com
- **Password**: @Tyrion99
- **Role**: vendor

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client for API calls
- `socket_io_client`: Real-time messaging

## Project Structure

```
lib/
├── data/
│   ├── api_service.dart      # API service for HTTP requests
│   ├── socket_service.dart   # Socket.IO service for real-time
│   └── models/              # Data models
│       ├── user.dart
│       ├── chat.dart
│       └── message.dart
├── viewmodel/
│   └── bloc/                # BLoC classes
│       ├── auth_bloc.dart   # Authentication state management
│       └── chat_bloc.dart   # Chat state management
├── view/                    # UI screens
│   ├── login_screen.dart    # Login screen
│   ├── home_screen.dart     # Chat list screen
│   └── chat_screen.dart     # Individual chat screen
└── main.dart               # App entry point
```

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **Model**: Data models and API services
- **View**: UI screens and widgets
- **ViewModel**: BLoC classes for state management

## State Management

Uses **BLoC (Business Logic Component)** pattern for:

- Authentication state (login/logout)
- Chat state (loading chats, messages)
- Real-time message updates

## Features Implementation

### Authentication

- Email/password login
- Role-based access (Customer/Vendor)
- Secure token management

### Chat Management

- List of user chats
- Real-time message sending/receiving
- Chat history retrieval
- Unread message indicators

### Real-time Communication

- Socket.IO integration
- Instant message delivery
- Chat room management

## Development Notes

- Built with Flutter 3.7.2+
- Uses Material Design 3
- Responsive design for various screen sizes
- Error handling and loading states
- Clean code structure with proper separation of concerns

## Future Enhancements

- File/image sharing
- Push notifications
- User profile management
- Chat search functionality
- Message encryption
- Offline message support
