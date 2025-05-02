# Active Context for NewsSphere

## Current Focus

Our current focus is on ensuring the app's offline capabilities are fully functional and bug-free:

1. **Offline Reading Feature**: We've just implemented the offline reading functionality, allowing users to save articles for reading without an internet connection.
   - The primary goal was to enable users to download articles from the latest news category.
   - Repository and ViewModel patterns were used to create a clean architecture.
   - Debug messages were added to track the data flow and operation of the feature.

2. **Navigation and Coordinator Pattern**: We've fixed issues with the coordinator pattern implementation:
   - Ensured proper parent-child relationships between coordinators
   - Fixed memory management issues with weak/strong references
   - Implemented proper parameter passing for article categories
   - Added debugging to make troubleshooting easier

## Recent Learnings

1. **Realm Storage Optimization**: We've learned that it's important to manage the Realm database efficiently:
   - Delete existing articles before saving new ones for offline reading
   - Added proper error handling to ensure data integrity
   - Created dedicated methods to manage articles lifecycle

2. **Coordinator Pattern Implementation**: We've gained insights into effectively implementing the coordinator pattern:
   - Strong references are needed in some cases to prevent premature deallocation
   - Parameters need to be properly passed through the coordinator chain
   - Debug logs help track the flow of navigation

3. **User Experience Considerations**:
   - Added loading indicators during network operations
   - Implemented empty state handling for offline articles
   - Added descriptive messages for user actions

## Next Steps

1. **Test offline reading functionality** on different network conditions
2. **Address SwiftLint warnings** throughout the codebase
3. **Enhance error handling** for edge cases in offline mode
4. **Optimize storage usage** by limiting the number of stored articles
5. **Improve UI feedback** for download progress

## Active Decisions

1. **Offline Storage Strategy**: We decided to clear all previously saved articles when the user downloads new ones, rather than appending.
   - Pros: Simpler implementation, avoids duplicate articles
   - Cons: User loses previously downloaded articles
   - Future enhancement: Add options for users to manage offline content

2. **Debug Logging Strategy**: We've added extensive debug logging to track the flow of data and operations.
   - This will help identify any issues in real usage
   - Should be refined or removed before production release

3. **UI Simplification**: Removed the "like" functionality from offline articles to simplify the UI
   - Interaction options are more limited in offline mode
   - Focus is on providing essential reading experience

## Recent Challenges

1. **Memory Management**: Ensuring proper memory management with the coordinator pattern has been challenging.
   - Solution: Careful use of weak/strong references and proper lifecycle management

2. **Realm Integration**: Working with Realm required careful consideration of threading and transaction handling.
   - Solution: Standardized use of transaction blocks and error handling

3. **SwiftLint Warnings**: The codebase has accumulated multiple SwiftLint warnings.
   - Solution: We're addressing them systematically, with focus on line length and formatting issues

## Current Codebase Health

1. **Strengths**:
   - Clean MVVM architecture with clear separation of concerns
   - Solid coordinator pattern implementation
   - Comprehensive repository pattern for data access
   - Good debugging infrastructure

2. **Areas for Improvement**:
   - Need more comprehensive unit tests
   - Some SwiftLint warnings to address
   - Documentation could be more thorough
   - UI polish needed in some areas

## Implementation Notes

The offline reading feature consists of several key components:

1. **OfflineArticleRepository**: Handles data operations for offline articles
   - Fetches articles from the network
   - Saves articles to Realm database
   - Retrieves saved articles for display
   - Manages article deletion

2. **ReadOfflineViewModel**: Manages the business logic for offline reading
   - Coordinates between the UI and the repository
   - Handles user actions (reload, delete)
   - Provides data for the UI

3. **ReadOfflineViewController**: Presents the UI for offline reading
   - Displays the list of saved articles
   - Provides controls for reloading and deleting articles
   - Shows loading indicators and empty states

4. **ReadOfflineTableViewCell**: Displays individual offline articles
   - Shows article image, title, source, and time
   - Simplified UI without like button

## Nhiệm vụ ưu tiên hiện tại

1. **Hoàn thiện Navigation Flow**:
   - Thêm transition animation mượt mà giữa các màn hình
   - Xử lý thống nhất NavigationBar trong toàn bộ ứng dụng

2. **Cải thiện ReadOffline Feature**:
   - Hoàn thiện UI/UX của ReadOfflineViewController
   - Triển khai chức năng lưu và truy xuất bài viết offline

3. **Location-based News**:
   - Hoàn thiện LocationViewController để chọn vị trí
   - Kết nối với API để lấy tin tức theo khu vực địa lý

4. **Tối ưu hóa Performance**:
   - Triển khai caching cho API calls
   - Tối ưu hóa image loading và memory usage

## Coding Patterns và Guidelines

Trong quá trình phát triển, cần tuân thủ các nguyên tắc sau:

### Debugging
- thêm print statements khi hoàn thành một tính năng để phát hiện lỗi nếu có
- Sử dụng proper logging system thay vì print statements
- Tránh force unwrapping (!) trong code production

### Coordinator Pattern
- Coordinator nên quản lý toàn bộ luồng điều hướng, không để ViewControllers điều hướng trực tiếp
- Sử dụng weak reference cho parentCoordinator để tránh retain cycles
- Strong reference từ parent đến child coordinators

### Memory Management
- Sử dụng [weak self] trong closures để tránh retain cycles
- Prefer value types (struct) over reference types (class) khi phù hợp
- Đảm bảo dọn dẹp resources trong deinit

### UI/UX Guidelines
- Màu nền chủ đạo: hexBackGround (dark theme)
- Text color: .white cho primary content, hex_Grey cho secondary content
- Nhất quán font size và spacing giữa các màn hình

## Pending Decisions

1. Có nên chuyển đổi sang SwiftUI cho một số component UI không? -> Không, chỉ dùng UIKit
2. Cách tiếp cận cho offline synchronization khi có network trở lại -> Nếu khả thi thì làm
3. Chiến lược caching tối ưu cho performance

## Những bài học và Insights

1. **Coordinator Pattern Complexity**: Mặc dù Coordinator Pattern cung cấp separation of concerns tốt, nó có thể phức tạp khi quản lý references và object lifecycle.

2. **ViewModels vs Domain Logic**: Cần phân biệt rõ ràng logic thuộc về ViewModel và logic thuộc về Domain Layer.

3. **Memory Management**: Cần cẩn thận với weak/strong references, đặc biệt trong các coordinator trees.

4. **UI Consistency**: Duy trì trải nghiệm UI nhất quán trong toàn bộ ứng dụng là thách thức, cần có design system rõ ràng.

## Notes & Observations

- Sử dụng UIKit với Stevia layout DSL cung cấp flexibility tốt, nhưng đôi khi phức tạp hơn SwiftUI
- Repository Pattern tạo điều kiện thuận lợi cho việc mocking data trong quá trình phát triển và testing
- Coordinator Pattern tạo ra một hệ thống điều hướng rõ ràng nhưng cần cẩn thận với object lifecycle

## Current Work Focus

Hiện tại dự án đang tập trung vào việc hoàn thiện kiến trúc Coordinator pattern, chức năng chia sẻ bài viết, và phát triển chức năng location, bao gồm các công việc sau:

1. **Hoàn thiện kiến trúc Coordinator**: Cải thiện cấu trúc phân cấp coordinator và tính nhất quán trong triển khai.
   - Thống nhất cách sử dụng protocols cho các coordinator
   - Cài đặt phương thức `start()` cho mỗi coordinator con
   - Đảm bảo kết nối đúng giữa ViewControllers và coordinators tương ứng

2. **Thay thế nút globeButton bằng shareButton**: Đã chỉnh sửa ArticleDetailViewController để thay thế chức năng mở trang web bằng chức năng chia sẻ bài viết.

3. **Phát triển tính năng Location**: Đang xây dựng chức năng cho phép người dùng chọn vị trí để lọc tin tức theo khu vực.
   - Đã tạo UI cơ bản cho LocationViewController
   - Đã thiết kế LocationListTableViewCell
   - Cần hoàn thiện Model và kết nối API

4. **Tuân thủ kiến trúc MVVM+Repository+Coordinator**:
   - Di chuyển logic business từ ViewController sang ViewModel
   - Đảm bảo ViewModel tương tác với Repository thay vì ViewController
   - Hoàn thiện điều hướng thông qua Coordinator

## Recent Changes

### Phát triển tính năng Location:
- **Tạo LocationViewController**: Màn hình cho phép tìm kiếm và chọn vị trí
- **Thiết kế LocationListTableViewCell**: Cell hiển thị thông tin vị trí
- **Chuẩn bị file Location.swift**: Cấu trúc model cho dữ liệu vị trí

### Cải thiện kiến trúc Coordinator:
- **Phân tích cấu trúc hiện tại**: Xác định cách MainCoordinator tương tác với các tab Coordinators
- **Xác định vấn đề**: Một số ViewControllers chưa được kết nối với coordinator tương ứng
- **Đề xuất giải pháp**: Sử dụng protocols để kết nối ViewControllers với các coordinator phù hợp

### Thay đổi UI và Chức năng:
- **Thay thế nút globeButton bằng shareButton**: 
  - Cập nhật ArticleDetailViewController để sử dụng chức năng shareArticle thay vì openWebView
  - Sửa lỗi tuân thủ giao thức ArticleContentViewDelegate

### Commits Đáng Chú Ý:
- **a08b83d7b9c7525156bdfecb11a776021c26d5b6** (category ui):
  - Triển khai giao diện danh mục
  - Thêm repository và model cho danh mục
  - Thêm tài nguyên màu sắc
  - Xây dựng UI cơ bản cho Discovery screen

- **37f248fdb84d78aded64ea14daa6b6251239692d** (discovery):
  - Thêm enum NewsCategory cho các loại tin tức
  - Thêm tài nguyên hình ảnh cho từng danh mục
  - Cải thiện UI của Discovery và CategoryArticles screen
  - Thêm CategoryArticlesCell để hiển thị chi tiết bài viết

## Next Steps

1. **Hoàn thiện cấu trúc Coordinator**:
   - Tạo protocols cho mỗi loại coordinator (HomeCoordinatorProtocol, DiscoveryCoordinatorProtocol...)
   - Cài đặt phương thức start() cho mỗi coordinator con
   - Đảm bảo mỗi ViewController được kết nối với coordinator thích hợp

2. **Tối ưu hóa trải nghiệm chia sẻ**: Cải thiện giao diện và các tùy chọn chia sẻ bài viết

3. **Hoàn thiện tính năng Location**:
   - Hoàn thiện model Location.swift
   - Kết nối API để lấy danh sách vị trí
   - Cài đặt chức năng tìm kiếm vị trí
   - Triển khai điều hướng từ HomeViewController đến LocationViewController

4. **Hoàn thiện việc tuân thủ kiến trúc**:
   - Hoàn thiện DiscoveryViewModel
   - Sử dụng coordinator cho điều hướng
   - Sửa các lỗi đặt tên và đăng ký cell

5. **Tạo file NewsCategoryType** trong Domain/Models để thay thế các file NewsCategory trùng lặp

## Active Decisions

1. **Phương án triển khai Coordinator Pattern**:
   - Sử dụng cấu trúc phân cấp đầy đủ với coordinator riêng cho mỗi tab
   - Kết nối mỗi ViewController với coordinator tương ứng qua protocol
   - Mỗi coordinator con quản lý luồng điều hướng riêng trong tab của nó

2. **Thay đổi cách tiếp cận chức năng chia sẻ**: 
   - Chuyển từ mở trang web (globeButton) sang chia sẻ bài viết trực tiếp (shareButton)
   - Đặt các phương thức giao thức trong extension riêng để tổ chức mã rõ ràng

3. **Thống nhất dùng enum NewsCategoryType** thay cho các enum NewsCategory trùng lặp để:
   - Duy trì type safety với Swift enum
   - Kết hợp các thuộc tính từ cả hai enum cũ (displayName, title, apiValue, image)
   - Đặt trong Domain/Models theo đúng kiến trúc

4. **Tiếp cận tính năng Location**:
   - Tách UI và data rendering để tuân thủ MVVM
   - Cần thiết kế model Location phù hợp để lưu trữ thông tin vị trí
   - Sử dụng delegate pattern để thông báo khi người dùng chọn vị trí

## Learnings & Insights

1. **Hiểu đúng về Coordinator Pattern**:
   - Coordinator không chỉ để ứng dụng chạy, mà để tổ chức code và quản lý luồng điều hướng
   - Mỗi coordinator nên có một phương thức start() để bắt đầu luồng điều hướng
   - Việc kết nối ViewController với coordinator nên thông qua protocols

2. **Tổ chức mã trong Swift**:
   - Sử dụng extension để tổ chức mã theo chức năng hoặc giao thức giúp code rõ ràng và dễ bảo trì
   - Tuân thủ giao thức cần được quản lý cẩn thận để tránh lỗi biên dịch

3. **Khác biệt giữa "chạy được" và "thiết kế tốt"**:
   - Ứng dụng có thể chạy được nhưng chưa chắc đã được thiết kế tốt
   - Cấu trúc rõ ràng nhất quán giúp dự án dễ bảo trì và mở rộng trong tương lai

4. **Cải thiện trải nghiệm người dùng**:
   - Việc chuyển từ nút mở web sang nút chia sẻ giúp người dùng chia sẻ nội dung nhanh hơn
   - Cần cân nhắc thêm các tùy chọn chia sẻ phổ biến 
   - Tính năng location sẽ cải thiện trải nghiệm bằng cách cung cấp tin tức phù hợp với vị trí của người dùng 