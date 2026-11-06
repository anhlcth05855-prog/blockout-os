# Block Out! - Color Sort Puzzle (iOS Swift / SwiftUI)

Dự án iOS Native hoàn chỉnh viết bằng **Swift 5.9+ & SwiftUI**, chuyển đổi 1:1 đầy đủ tất cả các tính năng và kiến trúc từ phiên bản **Android (Kotlin / Jetpack Compose)** tại `C:\Users\ASUS\Downloads\block out`.

Tham chiếu App Store: [Block Out! - Color Sort Puzzle](https://apps.apple.com/us/app/block-out-color-sort-puzzle/id6752672568)

---

## 📱 Bảng Ánh Xạ Kiến Trúc (Android vs iOS)

| Chức năng / Thành phần | Bản Android (Kotlin / Compose) | Bản iOS (Swift / SwiftUI) |
|---|---|---|
| **Màu sắc khối gạch** | `model/BlockColor.kt` | `Models/BlockColor.swift` (10 màu, hex & gradient 3D) |
| **Hướng trượt** | `model/SlideDirection.kt` | `Models/SlideDirection.swift` (horizontal, vertical, all) |
| **Cạnh cổng thoát** | `model/ExitSide.kt` | `Models/ExitSide.swift` (top, bottom, left, right) |
| **Cổng thoát màu** | `model/ExitDoor.kt` | `Models/ExitDoor.swift` |
| **Khối gạch đồ chơi** | `model/Block.kt` | `Models/Block.swift` (studs & symbol: star, diamond...) |
| **Chướng ngại vật** | `model/Obstacle.kt` | `Models/Obstacle.swift` (Rock, Lock, Crate) |
| **Dữ liệu màn chơi** | `model/Level.kt` | `Models/Level.swift` |
| **Tiến độ & Xu & Sao** | `model/GameProgress.kt` | `Models/GameProgress.swift` |
| **Bộ chủ đề (Themes)** | `model/ThemeItem` | `Models/ThemeItem.swift` (5 theme palettes) |
| **Nhiệm vụ (Missions)** | `model/Mission` | `Models/Mission.swift` |
| **Bộ máy vật lý & va chạm** | `engine/GameEngine.kt` | `Engine/GameEngine.swift` (DragLimits, combo 5x, undo, hint) |
| **Quản lý dữ liệu lưu** | `data/PreferencesManager.kt` | `Data/PreferencesManager.swift` (`UserDefaults` Codable) |
| **Kho 36+ màn & Daily** | `data/LevelRepository.kt` | `Data/LevelRepository.swift` (Level 1..5, 36, Daily) |
| **Âm thanh & Rung** | `sound/SoundManager.kt` | `Sound/SoundManager.swift` & `Sound/HapticManager.swift` |
| **Bàn cờ kéo trượt** | `GameBoardCanvas.kt` | `UI/Components/GameBoardCanvas.swift` (Chevrons, particles, scores) |
| **Thanh thông số** | `TopBar.kt` | `UI/Components/TopBar.swift` (Timer, Moves, 3-star tracker) |
| **Bộ 4 trợ thủ** | `BoosterBar.kt` | `UI/Components/BoosterBar.swift` (Undo, Hint, +5 Moves, Hammer) |
| **Hộp thoại Win/Lose** | `GameDialogs.kt` | `UI/Components/GameDialogs.swift` (WinDialog, GameOver, Settings) |
| **Màn hình chính** | `HomeScreen.kt` | `UI/Screens/HomeScreen.swift` |
| **Màn hình chơi game** | `GamePlayScreen.kt` | `UI/Screens/GamePlayScreen.swift` |
| **Màn hình chọn cấp độ** | `LevelSelectScreen.kt` | `UI/Screens/LevelSelectScreen.swift` (Lưới 36 màn chơi) |
| **Cửa hàng giao diện** | `ThemesScreen.kt` | `UI/Screens/ThemesScreen.swift` |
| **Màn hình nhiệm vụ** | `MissionsScreen.kt` | `UI/Screens/MissionsScreen.swift` |
| **Điều hướng ứng dụng** | `MainActivity.kt` | `App/ContentView.swift` & `App/BlockOutApp.swift` |

---

## 🎮 Chi Tiết Tính Năng & Cơ Chế Gameplay (Full Features)

1. **Vật lý trượt & Đồ họa Lego 3D (Toy-Brick Aesthetics)**:
   - Khối gạch với hiệu ứng viền vát 3D (bevel highlight), bóng đổ (shadow base) và đinh tán tròn (studs) ở tâm mỗi ô.
   - Hỗ trợ các biểu tượng nhận diện: ⭐ **Star**, 💎 **Diamond**, ⬛ **Square**, ⚪ **Circle**, ➕ **Cross**.
   - Ràng buộc trượt theo trục: Khối đứng chỉ trượt Dọc, Khối ngang chỉ trượt Ngang.
   - Cổng thoát neon 4 cạnh (*Top, Bottom, Left, Right*) nhấp nháy mũi tên chevron hướng ra ngoài. Khi trượt khối cùng màu vào đúng cổng, khối sẽ thoát ra ngoài bàn cờ kèm hiệu ứng nổ hạt Lego (Particle Sparks) và điểm số bay nổi (*Floating Score*).
   - Hệ thống **Combo Multiplier** lên đến 5x khi giải phóng liên tục các khối trong vòng 3.8 giây.

2. **Hệ thống 36+ Màn chơi & Thử thách hàng ngày (Daily Challenge)**:
   - **Level 1 - 3**: Nhập môn trượt gạch và cổng thoát 2-3 màu.
   - **Level 4**: Giới thiệu chướng ngại vật đá (*Rock Obstacle*).
   - **Level 5**: Bàn cờ 6x6 kẹt xe mật độ cao (*Grid Lock*).
   - **Level 6 - 35**: Hệ thống thuật toán tạo màn ngẫu nhiên nhưng đảm bảo **100% không trùng tọa độ (zero-overlap)** và có đường giải thoát hợp lệ.
   - **Level 36 ("The Canyon Mill")**: Tái hiện chuẩn xác bàn cờ 6x6, hệ thống cổng trắng, xanh dương, đen, tím, hồng, xanh lá, cam và giới hạn 34 lượt di chuyển.
   - **Daily Challenge (+100 Coins & Stars)**: Màn chơi ngẫu nhiên nhưng cố định (*deterministic*) theo ngày lịch thực tế (`year * 366 + dayOfYear`).

3. **Bộ 4 Trợ thủ (Boosters)**:
   - ↩️ **Undo**: Hoàn tác nước đi trước đó, phục hồi trạng thái khối.
   - 💡 **Hint**: Tự động tính toán đường đi và trượt khối có khả năng mở đường hoặc thoát ngay lập tức.
   - ➕ **+5 Moves**: Thêm 5 lượt di chuyển cứu nguy khi sắp hết lượt.
   - 🔨 **Hammer**: Kích hoạt chế độ đập búa, chạm vào bất kỳ khối gạch hay tảng đá chướng ngại vật nào để phá hủy ngay.

4. **Cửa hàng chủ đề (Themes Shop)**:
   - 5 bộ giao diện với bảng màu riêng biệt:
     - **Midnight Glow** (Mặc định - 0 xu): Bầu trời đêm sâu thẳm, độ tương phản cao.
     - **Sunny Meadow** (100 xu): Bầu trời xanh và đồng cỏ xanh tươi.
     - **Candy Cloud** (150 xu): Tông màu kẹo ngọt tím hồng pastel.
     - **Coral Sunset** (180 xu): Ánh hoàng hôn ấm áp và đường chân trời sa mạc.
     - **Underwater World** (200 xu): Đáy đại dương phát quang rực rỡ.

5. **Hệ thống Nhiệm vụ (Missions & Quests)**:
   - 6 nhiệm vụ phiêu lưu và hàng ngày:
     - *Puzzle Apprentice*: Giải 3 màn chơi (Thưởng 50 xu).
     - *Path Finder*: Giải 10 màn chơi (Thưởng 150 xu).
     - *Swift Thinker*: Thắng 3 màn với 5 lượt đi trở xuống (Thưởng 80 xu).
     - *Par Perfection*: Thắng 5 màn đạt chuẩn mốc Par (Thưởng 100 xu).
     - *Starlight Collector*: Thu thập đủ 15 sao vàng (Thưởng 60 xu).
     - *Daily Adventurer*: Hoàn thành thử thách Daily hôm nay (Thưởng 100 xu).
   - Thanh tiến độ động và nút **CLAIM** nhận thưởng xu trực tiếp.

6. **Âm thanh & Rung xúc giác (Audio & Haptics)**:
   - Click, trượt gạch, tiếng chuông thoát khối, combo fanfare, thắng màn, thua màn và tiếng búa đập đá.
   - Haptic Feedback êm ái qua `UIImpactFeedbackGenerator` và `UINotificationFeedbackGenerator`.

---

## 📁 Cấu Trúc File Dự Án (Source Code Tree)

```text
c:\Users\ASUS\Downloads\blockout ios\
├── Package.swift                                      # Swift Package Manager manifest
├── README.md                                          # Tài liệu hướng dẫn
├── Sources/
│   └── BlockOutGame/
│       ├── App/
│       │   ├── BlockOutApp.swift                      # @main Entry point ứng dụng
│       │   └── ContentView.swift                      # Điều hướng màn hình (Home, Game, LevelSelect, Themes, Missions)
│       ├── Models/
│       │   ├── BlockColor.swift                       # 10 màu sắc khối (hex, dark, light, stud)
│       │   ├── SlideDirection.swift                   # Hướng trượt (horizontal, vertical, all)
│       │   ├── ExitSide.swift                         # Cạnh cổng (top, bottom, left, right)
│       │   ├── ExitDoor.swift                         # Vị trí & màu cổng thoát
│       │   ├── Block.swift                            # Thực thể khối gạch, studs & symbol
│       │   ├── Obstacle.swift                         # Tảng đá chướng ngại vật
│       │   ├── Level.swift                            # Cấu hình màn chơi
│       │   ├── GameProgress.swift                     # Dữ liệu lưu trữ (xu, sao, lượt bổ trợ)
│       │   ├── ThemeItem.swift                        # Cấu trúc dữ liệu bộ chủ đề
│       │   └── Mission.swift                          # Cấu trúc dữ liệu nhiệm vụ
│       ├── Engine/
│       │   └── GameEngine.swift                       # Bộ máy vật lý, tính giới hạn trượt, va chạm, combo, Undo, Hint
│       ├── Data/
│       │   ├── LevelRepository.swift                  # 36 màn chơi, Canyon Mill & Daily Puzzle generator
│       │   └── PreferencesManager.swift               # Lưu trữ dữ liệu UserDefaults Codable
│       ├── Sound/
│       │   ├── SoundManager.swift                     # Âm thanh hiệu ứng AudioToolbox
│       │   └── HapticManager.swift                    # Rung xúc giác UIImpactFeedbackGenerator
│       └── UI/
│           ├── Components/
│           │   ├── GameBoardCanvas.swift              # Canvas kéo trượt 120fps, hiệu ứng hạt pháo hoa & điểm số bay
│           │   ├── TopBar.swift                       # Thanh đếm giờ, mốc 3 sao & lượt đi
│           │   ├── BoosterBar.swift                   # Thanh 4 bổ trợ (Undo, Hint, +5 Moves, Hammer)
│           │   └── GameDialogs.swift                  # Dialog Chiến thắng, Thua cuộc, Cài đặt
│           └── Screens/
│               ├── HomeScreen.swift                   # Màn hình chính
│               ├── GamePlayScreen.swift               # Màn hình chơi game chính
│               ├── LevelSelectScreen.swift            # Màn hình chọn 36 cấp độ
│               ├── ThemesScreen.swift                 # Màn hình cửa hàng giao diện
│               └── MissionsScreen.swift               # Màn hình nhiệm vụ nhận xu
└── Tests/
    └── BlockOutGameTests/
        └── BlockOutGameTests.swift                    # Unit Tests kiểm thử logic game
```

---

## 🚀 Hướng Dẫn Mở & Chạy Dự Án Trong Xcode

### Cách 1: Thêm vào Xcode Project mới (Dễ nhất)
1. Mở **Xcode** trên macOS ➔ Chọn **Create a new Xcode project**.
2. Chọn **iOS** ➔ **App** ➔ Đặt tên là `BlockOut`, Interface: **SwiftUI**, Language: **Swift**.
3. Xóa file `ContentView.swift` mặc định mà Xcode tự sinh.
4. Kéo thư mục `Sources/BlockOutGame` vào cây thư mục project trong Xcode (nhớ tick chọn *"Copy items if needed"* và *"Create groups"*).
5. Nhấn `Cmd + R` để chạy trên iPhone Simulator hoặc thiết bị thật (iOS 16, 17, 18).

### Cách 2: Mở trực tiếp qua Swift Package
1. Mở **Xcode** ➔ Chọn **File** ➔ **Open...** ➔ Chọn thư mục `c:\Users\ASUS\Downloads\blockout ios` chứa file `Package.swift`.
2. Xcode sẽ tải package và cho phép chạy toàn bộ bộ Unit Tests (`Cmd + U`).
