# Technical Context

## Technology Stack

### Core Frameworks
- **UIKit**: Framework UI chính cho ứng dụng
- **Foundation**: Cung cấp các cấu trúc dữ liệu cơ bản và utilities
- **Stevia**: Layout DSL giúp viết UI code ngắn gọn hơn Auto Layout thuần

### Networking
- **URLSession**: Giao tiếp với API backend 
- **NewsData.io API**: Nguồn dữ liệu cho bài viết tin tức
- **Kingfisher**: Tải và cache hình ảnh hiệu quả

### Persistence
- **Realm**: Local database, lưu trữ bài viết offline và bookmarks
- **UserDefaults**: Lưu trữ user preferences và application state

### Other Libraries
- **Firebase**: Analytics và push notifications 
- **SwiftLint**: Đảm bảo code style nhất quán

## Development Environment

- **Xcode**: IDE chính cho phát triển
- **iOS Simulator**: Test trên các thiết bị ảo
- **iOS 14+**: Target deployment
- **Swift 5.5+**: Ngôn ngữ lập trình chính

## Architecture & Design

- **MVVM**: Model-View-ViewModel pattern 
- **Repository Pattern**: Quản lý dữ liệu và truy cập API
- **Coordinator Pattern**: Điều hướng giữa các màn hình
- **Protocol-Oriented Programming**: Sử dụng protocols để định nghĩa interfaces

## Folder Structure

```
NewsSphere/
├── Application/         # App lifecycle and initialization
├── Presentation/        # UI layer
│   ├── Coordinators/    # Navigation management
│   ├── Scenes/          # View controllers
│   └── ViewModels/      # View models
├── Domain/              # Business logic
│   ├── Entities/        # Model objects
│   ├── Repositories/    # Data access protocols
│   └── UseCases/        # Business use cases
├── CustomView/          # Reusable UI components
├── Helper/              # Utility functions
├── Extensions/          # Swift extensions
└── Resources/           # Assets, strings, etc.
```

## APIs and Integrations

### News API (NewsData.io)
- Base URL: `https://newsdata.io/api/1/`
- Endpoints:
  - `/latest`: Lấy tin tức mới nhất
  - Parameters:
    - `category`: sports, business, crime, domestic...
    - `language`: en, vi...
    - `apikey`: API key

### Firebase Integration
- Analytics for user behavior tracking
- Push notifications for breaking news
- Crash reporting

## Coding Standards

- **Swift Style Guide**: Tuân theo Swift API Design Guidelines
- **Access Control**: Sử dụng private/fileprivate khi có thể
- **Documentation**: Tất cả public APIs đều có documentation
- **Error Handling**: Sử dụng Result type và custom Error enums
- **Memory Management**: Cẩn thận với cycles, sử dụng [weak self] khi cần

## Testing Approach

- **Unit Tests**: Tập trung vào testing ViewModels và Repositories
- **UI Tests**: Kiểm tra user flows chính
- **Mock Objects**: Sử dụng protocol-based mocking cho testing

## Development Setup
- Clone repository
- Mở file .xcodeproj bằng Xcode
- Build và run trên simulator hoặc device thực tế

## Technical Constraints
- **API Rate Limits**: NewsData.io API có giới hạn số lượng request mỗi ngày
- **Image Caching**: Cần implement caching để tối ưu hiệu suất tải ảnh
- **Memory Management**: Cần chú ý quản lý memory cycle, đặc biệt trong các closure

## Dependencies
- Thư viện Stevia cho UI Layout
- NewsData.io API cho dữ liệu tin tức
- Firebase (dự kiến) cho authentication và storage

## Tool Usage Patterns
- **Git Flow**: Feature branches, pull requests, code reviews
- **Dependency Management**: Swift Package Manager (dự kiến)
- **Coding Standards**: Tuân thủ Swift style guide của Apple
- **Documentation**: Sử dụng comments và documentation comments (///) cho API public 