# Progress

## Project Status Overview

NewsSphere đang trong giai đoạn phát triển tích cực, với nhiều tính năng cốt lõi đã hoàn thành và sẵn sàng cho testing.

| Thành phần               | Trạng thái     | Chi tiết                                        |
|--------------------------|----------------|------------------------------------------------|
| Core Architecture        | ✅ Completed    | MVVM + Repository + Coordinator                 |
| UI Framework             | ✅ Completed    | UIKit với Stevia layout                         |
| API Integration          | ✅ Completed    | NewsData.io API integration                     |
| Tab Navigation           | ✅ Completed    | Hoạt động mượt mà giữa các tab                  |
| Detailed News View       | ✅ Completed    | Hiển thị nội dung chi tiết bài viết            |
| Categories               | ✅ Completed    | Tổ chức tin tức theo danh mục                   |
| Bookmarking              | ✅ Completed    | Lưu và quản lý bài viết yêu thích              |
| Location-based News      | 🟡 In Progress  | UI đã hoàn thiện, đang kết nối API             |
| Offline Reading          | 🟡 In Progress  | Đang triển khai lưu trữ và truy xuất           |
| Search                   | 🟡 In Progress  | UI đã hoàn thiện, đang cải thiện kết quả       |
| User Authentication      | ⚪ Planned      | Firebase Auth sẽ được triển khai                |
| Push Notifications       | ⚪ Planned      | Firebase Cloud Messaging                        |
| Analytics                | ⚪ Planned      | Firebase Analytics                              |

## Recent Achievements

### Week 1-2: Foundation
- ✅ Thiết lập kiến trúc cơ bản MVVM + Repository + Coordinator
- ✅ Tích hợp NewsData.io API
- ✅ Xây dựng màn hình Home với horizontal và vertical collection views

### Week 3-4: Navigation & Articles
- ✅ Triển khai navigation flow với Coordinator pattern
- ✅ Hoàn thiện Article Detail view với full content và hình ảnh
- ✅ Thêm Category filtering và top bar categories
- ✅ Xây dựng Discovery screen với grid layout

### Week 5-6: User Experience
- ✅ Triển khai bookmark feature
- ✅ Thêm location-based UI cho tin tức địa phương
- ✅ Thiết kế ReadOffline screen và flow điều hướng
- ✅ Cải thiện Performance và UI polish

### Week 7 (Hiện tại): Bugfixes & Refinement
- ✅ Sửa lỗi coordinator navigation flow
- ✅ Khắc phục vấn đề hiển thị category trong article detail
- ✅ Loại bỏ debug code
- ✅ Cải thiện memory management
- 🟡 Đang triển khai animation transitions

## Known Issues

1. **Memory Management**
   - Có thể có retain cycles trong coordinator hierarchy nếu không cẩn thận với strong/weak references
   - Cần review việc sử dụng `[weak self]` trong closures

2. **UI Consistency**
   - NavigationBar hiển thị không nhất quán trong một số màn hình
   - Contrast ratio chưa tối ưu cho accessibility

3. **Performance**
   - Image loading có thể gây lag khi scroll nhanh qua nhiều bài viết
   - Khi offline mode, lần load đầu tiên có độ trễ

## Next Steps

### Immediate (1-2 Weeks)
1. Hoàn thiện Location feature với API integration
2. Cải thiện Offline Reading functionality
3. Tối ưu hóa image loading và caching

### Short-term (3-4 Weeks)
1. Triển khai User Preferences
2. Thêm UI animations và transitions
3. Tích hợp Firebase analytics

### Longer-term (1-3 Months)
1. Thêm User Authentication
2. Triển khai Push Notifications
3. Tích hợp thêm News sources
4. Xây dựng personalized recommendations

## Lessons Learned

1. **Coordinator Pattern**
   - Rất hiệu quả cho navigation flow phức tạp
   - Cần cẩn thận với object references và lifecycle
   - Cần documentation rõ ràng cho các coordinator interaction

2. **Repository Pattern**
   - Giúp tách biệt data sources và business logic
   - Tạo điều kiện thuận lợi cho testing với mock repositories
   - Cung cấp flexibility để thay đổi data sources trong tương lai

3. **Memory Management trong Swift**
   - Cần chú ý đặc biệt đến weak/strong references trong closures
   - Cần careful monitoring để tránh retain cycles
   - Cần kiểm tra deinit được gọi đúng cách

4. **API Integration**
   - NewsData.io API đôi khi không nhất quán trong response format
   - Cần robust error handling và fallbacks
   - Rate limiting cần được xử lý gracefully

## Architecture Decisions

### MVVM + Coordinator pattern + Repository pattern

MVVM được chọn vì:
- Testability tốt
- Separation of concerns rõ ràng
- Binding dễ dàng giữa ViewModel và View

Coordinator được thêm vào để:
- Tách biệt navigation logic khỏi ViewControllers
- Quản lý flow phức tạp qua nhiều màn hình
- Cải thiện reusability của ViewControllers

### Repository Pattern

Repository được triển khai để:
- Abstract away data source implementation
- Dễ dàng switch giữa API và local cache
- Cung cấp consistent interface cho ViewModels

### UIKit + Stevia

UIKit + Stevia được chọn thay vì SwiftUI vì:
- Backward compatibility với iOS 14+
- Stevia cung cấp syntax ngắn gọn hơn Auto Layout thuần
- Flexibility và control cao hơn SwiftUI trong một số trường hợp

## What Works

### Core Features
- ✅ **API Integration**: Kết nối thành công với NewsData.io API
- ✅ **Discovery Screen**: Hiển thị các danh mục tin tức với giao diện grid
- ✅ **Category Filter**: Tìm kiếm danh mục theo keyword
- ✅ **Navigation**: Điều hướng cơ bản giữa các màn hình
- ✅ **Article Sharing**: Chức năng chia sẻ bài viết trực tiếp thay vì mở trang web

### UI Components
- ✅ **DiscoveryCell**: Cell hiển thị danh mục với hình ảnh và tiêu đề
- ✅ **CategoryArticlesCell**: Cell hiển thị bài viết với hình ảnh, tiêu đề, nguồn
- ✅ **TopBarView**: Thanh danh mục ngang trên màn hình chính
- ✅ **Color Assets**: Bộ màu sắc chính đã được thiết lập (C01D2E, 1B1B1B, B9B9B6)
- ✅ **Share Button**: Nút chia sẻ bài viết trong màn hình chi tiết

### Architecture
- ✅ **MVVM Structure**: Các file đã được tổ chức theo mô hình MVVM
- ✅ **Repository Layer**: Repository pattern đã được triển khai cho data access
- ✅ **Basic Coordinator Setup**: Cấu trúc cơ bản của Coordinator pattern đã được thiết lập
- ✅ **Protocol Conformance**: Sử dụng extension để tổ chức code theo giao thức

## What's Left To Build

### Core Features
- ❌ **Advanced Sharing Options**: Cải thiện trải nghiệm chia sẻ với các tùy chọn phổ biến
- ❌ **Search**: Tìm kiếm bài viết
- ❌ **Bookmarks**: Lưu và quản lý bài viết yêu thích
- ❌ **Read Offline**: Tính năng đọc offline
- ❌ **User Authentication**: Đăng nhập, đăng ký, và quản lý profile
- ❌ **Notification**: Thông báo tin tức mới
- ❌ **Location Setting**: Chọn vị trí để nhận tin tức theo khu vực

### Architecture Improvements
- ❌ **Complete Coordinator Pattern**: Hoàn thiện cấu trúc Coordinator với protocols đầy đủ
- ❌ **Coordinator Start Methods**: Thêm phương thức start() cho mỗi coordinator con
- ❌ **Protocol-Based Coordinator Connection**: Kết nối ViewControllers với Coordinators qua protocol
- ❌ **Child Coordinator Lifecycle**: Quản lý vòng đời của coordinator con (childDidFinish)

### Technical Improvements
- ❌ **Image Caching**: Cần triển khai giải pháp cache hình ảnh
- ❌ **Error Handling**: Cải thiện xử lý lỗi khi gọi API
- ❌ **Unit Testing**: Viết test cho các component chính
- ❌ **State Management**: Quản lý state tốt hơn với các loading/error states
- ❌ **Accessibility**: Cải thiện trải nghiệm cho người dùng khuyết tật

## Current Status

### Đang Triển Khai
- 🔄 **Hoàn thiện Coordinator Pattern**: Đang cải thiện cấu trúc phân cấp và kết nối
- ✅ **Tính năng chia sẻ bài viết**: Đã thay thế nút globeButton bằng shareButton
- 🔄 **Sửa lỗi trùng lặp NewsCategory**: Đang tạo file NewsCategoryType thống nhất
- 🔄 **Cải thiện Discovery Screen**: Hoàn thiện UI và hiệu suất
- 🔄 **Chức năng Location**: Đang phát triển UI cho tính năng chọn location

### Đã Hoàn Thành Gần Đây
- ✅ **Phân tích Coordinator Pattern**: Hiểu rõ hơn về cách triển khai đúng
- ✅ **Sửa lỗi tuân thủ ArticleContentViewDelegate**: Thêm phương thức shareButtonTapped()
- ✅ **Chức năng chia sẻ bài viết**: Thay thế chức năng mở web bằng chia sẻ
- ✅ **Discovery UI**: Basic UI cho màn hình Discovery
- ✅ **Category Repository**: Lấy danh mục từ API
- ✅ **Image Assets**: Thêm hình ảnh cho các danh mục

### Tiếp Theo
- 📅 **Triển khai protocols cho Coordinators**: Tạo các giao diện như HomeCoordinatorProtocol
- 📅 **Cài đặt start() cho coordinators**: Thêm phương thức bắt đầu cho mỗi coordinator
- 📅 **Tối ưu trải nghiệm chia sẻ**: Cải thiện các tùy chọn chia sẻ
- 📅 **CategoryArticles Screen**: Hoàn thiện và sửa lỗi
- 📅 **ViewModel Logic**: Di chuyển business logic vào ViewModel
- 📅 **Coordinator Flow**: Cải thiện điều hướng qua Coordinator
- 📅 **Location Model**: Hoàn thiện model Location và kết nối API

## Known Issues

1. **Kết nối Coordinator chưa nhất quán**:
   - HomeViewController được kết nối với MainCoordinator thay vì HomeCoordinator (đã fix, đã đổi sang HomeCoordinator)

2. **Trùng lặp enum NewsCategory**: Có hai file định nghĩa NewsCategory (đã fix)

3. **UI Bugs**:
   - Lỗi đăng ký cell trong CategoryArticlesViewController
   - Hiển thị ảnh chưa đúng tỷ lệ trong một số cell

4. **Kiến trúc**:
   - DiscoveryViewController đang gọi trực tiếp repository
   - DiscoveryViewModel chưa được sử dụng đúng cách
   - Điều hướng chưa hoàn toàn sử dụng Coordinator

5. **Location Feature**:
   - Model Location chưa được định nghĩa
   - Chưa có data source cho danh sách location
   - LocationViewController UI đã dựng nhưng chưa có xử lý dữ liệu

## Evolution of Project Decisions

### Kiến trúc
**Ban đầu**: Sử dụng MVC đơn giản  
**Hiện tại**: MVVM + Repository + Coordinator  
**Lý do**: Cần cấu trúc rõ ràng hơn để dễ bảo trì và mở rộng

### Coordinator Pattern
**Ban đầu**: Sử dụng coordinator đơn giản, kết nối trực tiếp  
**Hiện tại**: Hướng tới cấu trúc phân cấp coordinator với protocols  
**Lý do**: Tách biệt rõ ràng trách nhiệm, giảm sự phụ thuộc, dễ mở rộng

### UI/UX Improvements
**Ban đầu**: Mở trang web khi nhấn vào nút globeButton  
**Hiện tại**: Chia sẻ bài viết trực tiếp với nút shareButton  
**Lý do**: Cải thiện trải nghiệm người dùng, cho phép chia sẻ nhanh hơn

### Quản lý danh mục
**Ban đầu**: Lấy danh mục từ API  
**Hiện tại**: Sử dụng enum với các case cố định  
**Lý do**: Giảm phụ thuộc vào API, tăng type safety và hiệu suất

### UI Framework
**Ban đầu**: Storyboard  
**Hiện tại**: Programmatic UI với Stevia  
**Lý do**: Dễ dàng quản lý code, giảm xung đột khi làm việc nhóm 

## Latest Updates

### (4/28/2025) Implemented Offline Reading Feature
- Created OfflineArticleRepository for managing offline articles with Realm
- Developed ReadOfflineViewModel to handle business logic
- Updated ReadOfflineViewController and ReadOfflineTableViewCell UI
- Added functionality to download and store articles from latest news category
- Implemented debugging logs to monitor the offline functionality
- Fixed navigation and parameter handling in coordinators

### (4/26/2025) Fixed Coordinator and Navigation Issues
- Fixed issue with parent coordinators being nil
- Implemented proper memory management with weak/strong references
- Added correct showing of article details from different views
- Ensured category labels are displayed correctly
- Improved debugging with meaningful console logs
- Fixed navigation to Location and Read Offline screens

### (4/25/2025) Article Detail View Implementation
- Added WebView container for article content
- Implemented share functionality
- Created bookmarking feature
- Added article metadata display

### (4/24/2025) Basic App Structure and Navigation
- Established MVVM architecture with Repository and Coordinator patterns
- Created base coordinators for main sections
- Implemented core UI components
- Set up network layer for API communication
- Designed Realm storage for offline persistence

## Technical Debt

1. **Linting issues**: There are SwiftLint warnings to be addressed
2. **Force unwrapping**: Some code uses force unwrapping, should replace with optional binding
3. **Documentation**: Need more comprehensive code documentation
4. **Unit Testing**: Test coverage is minimal and needs improvement
5. **UI Refinement**: Some screens need design polish and consistent styling

## Next Steps

1. Complete integration with Location-based news API
2. Expand test coverage
3. Refine search functionality
4. Implement user account functionality
5. Begin work on customized news feed algorithm

## Milestone Tracking

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| Core architecture | 4/15/2025 | ✅ Completed |
| Basic news browsing | 4/20/2025 | ✅ Completed |
| Article interaction | 4/25/2025 | ✅ Completed |
| Offline capabilities | 4/30/2025 | ✅ Completed |
| User accounts | 5/10/2025 | 🔄 In Progress |
| Social features | 5/20/2025 | 📝 Planned |
| Advanced personalization | 6/1/2025 | 📝 Planned | 