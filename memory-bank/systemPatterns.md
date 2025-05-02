# System Patterns

## Architecture Overview

NewsSphere sử dụng kiến trúc MVVM kết hợp với Repository Pattern và Coordinator Pattern. Kiến trúc này giúp tách biệt rõ ràng các thành phần, cải thiện khả năng bảo trì và mở rộng.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Views    │◄───┤  ViewModels │◄───┤ Repositories │◄───┤  API/Local  │
│             │    │             │    │             │    │  Data Source │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       ▲                                                        
       │                                                        
       │           ┌─────────────┐                              
       └───────────┤ Coordinators│                              
                   └─────────────┘                              
```

## MVVM Pattern

### View Layer
- **ViewControllers**: `HomeViewController`, `DiscoveryViewController`, `ProfileViewController`, v.v.
- Chỉ chứa code liên quan đến UI và user interaction
- Sử dụng binding để cập nhật UI từ ViewModel

### ViewModel Layer
- **ViewModels**: `HomeViewModel`, `ArticleDetailViewModel`, v.v.
- Chứa business logic và data transformation
- Sử dụng closure callbacks để thông báo cho View

### Model Layer
- **Entities/Models**: `Article`, `NewsCategoryType`, v.v.
- Cấu trúc dữ liệu cơ bản của ứng dụng

## Repository Pattern

Repositories đóng vai trò trung gian giữa ViewModels và nguồn dữ liệu:

- **ArticleRepository**: Quản lý việc lấy và lưu trữ bài viết
- **BookmarkRepository**: Quản lý bài viết được đánh dấu yêu thích
- **CategoryRepository**: Quản lý danh mục tin tức

Mỗi repository tuân theo interface riêng (protocol), giúp dễ dàng thay đổi implementation và unit testing.

## Coordinator Pattern

Coordinators quản lý luồng điều hướng trong ứng dụng:

- **AppCoordinator**: Điểm khởi đầu, quản lý luồng Authentication/Main
- **MainCoordinator**: Quản lý các tab chính (Home, Discovery, Notice, Profile)
- **HomeCoordinator**, **DiscoveryCoordinator**, **ProfileCoordinator**: Quản lý điều hướng trong mỗi tab

### Flow điều hướng điển hình:

```
AppCoordinator
    ├── AuthCoordinator (if needed)
    └── MainCoordinator
        ├── HomeCoordinator
        │   └── ArticleDetailCoordinator
        ├── DiscoveryCoordinator
        ├── NoticeCoordinator
        └── ProfileCoordinator
```

## Data Flow

1. **User Action** → View Controller gọi phương thức trên ViewModel
2. **ViewModel** → Gọi Repository để lấy/lưu dữ liệu
3. **Repository** → Truy cập API hoặc local database
4. **Repository** → Trả dữ liệu về ViewModel
5. **ViewModel** → Xử lý và chuyển đổi dữ liệu
6. **ViewModel** → Thông báo View thông qua callback
7. **View** → Cập nhật UI

## Communication Patterns

- **View → ViewModel**: Direct method calls
- **ViewModel → View**: Closures/callbacks
- **ViewModel → Repository**: Direct method calls
- **ViewModel → Coordinator**: Direct method calls (thông qua delegate pattern)
- **Coordinator → Coordinator**: Parent-child relationship (weak references)

## Module Organization

```
NewsSphere/
├── Application/         # App lifecycle
├── Presentation/        # UI Layer
│   ├── Coordinators/    # Navigation
│   ├── Scenes/          # View Controllers
│   └── ViewModels/      # Business Logic
├── Domain/              # Business Rules
│   ├── Entities/        # Core Models
│   ├── Repositories/    # Data Access
│   └── UseCases/        # Business Logic
├── CustomView/          # Reusable UI Components
└── Utils/               # Helpers & Extensions
```

## Key Design Decisions

1. **Strong Separation of Concerns**: Mỗi component có một nhiệm vụ rõ ràng
2. **Unidirectional Data Flow**: Data flows từ repository → viewmodel → view
3. **Coordinator-based Navigation**: Tách biệt navigation logic khỏi view controllers
4. **Protocol-based Repositories**: Dễ dàng thay đổi và test

## Design Patterns

### MVVM (Model-View-ViewModel)
- **Model**: Định nghĩa dữ liệu cơ bản và logic nghiệp vụ
  - Ví dụ: `Article`, `User`, `NewsCategoryType`, `Location`
- **View**: Hiển thị dữ liệu và chuyển sự kiện người dùng đến ViewModel
  - Ví dụ: `DiscoveryViewController`, `CategoryArticlesCell`, `LocationViewController`
- **ViewModel**: Quản lý logic hiển thị và cung cấp dữ liệu cho View
  - Ví dụ: `DiscoveryViewModel`, `CategoryArticlesViewModel`, `LocationViewModel` (dự kiến)

### Repository Pattern
- Tạo một lớp trung gian giữa nguồn dữ liệu (API, database) và phần còn lại của ứng dụng
- Cung cấp interface đơn giản và thống nhất để truy cập dữ liệu
- Ví dụ: `CategoryRepository`, `ArticleRepository`, `LocationRepository` (dự kiến)
- Giúp tách biệt logic truy xuất dữ liệu khỏi ViewModel

### Coordinator Pattern
- Quản lý luồng điều hướng và chuyển màn hình trong ứng dụng
- Giảm sự phụ thuộc giữa các ViewControllers
- Tổ chức phân cấp: AppCoordinator → MainCoordinator → TabCoordinators
- Mỗi coordinator chịu trách nhiệm cho một luồng màn hình cụ thể

#### Cấu trúc Coordinator trong NewsSphere
- **AppCoordinator**: Điều phối luồng chính của ứng dụng (Auth/Main)
- **MainCoordinator**: Quản lý TabBar và các coordinator con
- **Tab Coordinators**: HomeCoordinator, DiscoveryCoordinator, NoticeCoordinator, ProfileCoordinator

#### Triển khai Coordinator đúng cách
- Mỗi Coordinator cần có phương thức `start()` để khởi động luồng điều hướng
- Sử dụng protocols cho việc kết nối giữa Coordinators và ViewControllers
- Quản lý parent-child relationship giữa các coordinators
- Xử lý vòng đời coordinator qua `childDidFinish()`

#### Protocols cho Coordinators
```swift
protocol HomeCoordinatorProtocol: AnyObject {
    func showArticleDetail(_ article: Article)
    func showLocationSelection()
}

class HomeCoordinator: Coordinator, HomeCoordinatorProtocol {
    // Implementation
}

class HomeViewController: UIViewController {
    var coordinator: HomeCoordinatorProtocol?
}
```

### Protocol-Oriented Programming
- Sử dụng protocol để định nghĩa các hành vi và yêu cầu
- Tuân thủ protocol được triển khai qua extension
- Tổ chức code thành các phần chức năng rõ ràng
- Ví dụ: `ArticleContentViewDelegate` được tuân thủ trong extension của `ArticleDetailViewController`
- Giúp dễ dàng bảo trì và mở rộng chức năng

## Component Relationships

```
┌───────────────┐      ┌───────────────┐      ┌───────────────┐
│   View Layer  │      │ ViewModel Layer│      │Repository Layer│
│ (Controllers) │◄────►│  (ViewModels)  │◄────►│ (Repositories) │
└───────────────┘      └───────────────┘      └───────────────┘
        ▲                                            ▲
        │                                            │
        │                                            ▼
┌───────────────┐                         ┌───────────────┐
│  Coordinator  │                         │  Data Sources │
│    Layer      │                         │  (API, Local) │
└───────────────┘                         └───────────────┘
```

## Coordinator Hierarchy

```
┌─────────────────┐
│ AppCoordinator  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ MainCoordinator │
└┬───────┬───────┬┘
 │       │       │
 ▼       ▼       ▼
┌────┐ ┌────┐ ┌────┐
│Home│ │Disc│ │More│
│Cord│ │Cord│ │Cord│
└────┘ └────┘ └────┘
```

## Critical Implementation Paths

### Fetch and Display News Articles
1. ViewModel yêu cầu Repository lấy dữ liệu
2. Repository gọi API và xử lý response
3. Repository chuyển dữ liệu về cho ViewModel
4. ViewModel định dạng dữ liệu và cung cấp cho View
5. View hiển thị dữ liệu

### Navigation Flow
1. User tương tác với UI (ví dụ: tap vào một danh mục)
2. ViewController thông báo cho Coordinator
3. Coordinator tạo ViewController mới
4. Coordinator điều hướng đến màn hình mới (push/present)

### Share Article Flow
1. User nhấn vào nút share trong ArticleDetailViewController
2. ArticleDetailViewController gọi viewModel.shareArticle()
3. ViewModel chuyển yêu cầu đến Coordinator
4. Coordinator hiển thị màn hình chia sẻ của hệ thống iOS
5. User chọn ứng dụng để chia sẻ bài viết

### Location Selection Flow (Dự kiến)
1. User chọn tùy chọn cài đặt vị trí trong HomeViewController
2. HomeViewController thông báo cho HomeCoordinator
3. HomeCoordinator tạo và trình bày LocationViewController
4. User tìm kiếm và chọn vị trí từ danh sách
5. LocationViewController thông báo cho HomeCoordinator location đã chọn
6. HomeCoordinator chuyển thông tin về HomeViewController
7. HomeViewController cập nhật tin tức dựa trên vị trí đã chọn
## Architectural Decisions
- **Dependency Injection**: Truyền dependencies qua constructor để dễ kiểm thử
- **Protocol-Oriented**: Sử dụng protocol để định nghĩa interface, tăng tính module hóa
- **Extension-Based Organization**: Tổ chức code theo chức năng và tuân thủ protocol bằng extension
- **Clean Architecture Principles**: Tách biệt các layer, mỗi layer có trách nhiệm riêng biệt
- **Swift's Type Safety**: Tận dụng type safety của Swift với enum, struct 
