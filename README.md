# 🎓 EduFlow - Advanced Learning Management System (LMS)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Bloc](https://img.shields.io/badge/state_management-BLoC-%2399ccff.svg?style=for-the-badge)
![Hydrated](https://img.shields.io/badge/persistence-Hydrated_Bloc-success.svg?style=for-the-badge)

**EduFlow** is a production-grade, offline-first mobile application engineered with **Flutter**. It facilitates a comprehensive educational ecosystem by connecting instructors and students through a dual-role architecture. The system is built on a robust state management foundation using **Hydrated BLoC**, ensuring data persistence and reliability without requiring an active internet connection.




---

## 🚀 Key Technical Features

### 1. Advanced State Management & Persistence
* **Offline-First Architecture:** Utilized `hydrated_bloc` to serialize and persist complex application states (Courses, Students, Attendance Records, Video Metadata) directly to local storage.
* **State Restoration:** The app seamlessly restores the user's session and data across app restarts, ensuring zero data loss for critical academic records.

### 2. Role-Based Access Control (RBAC)
* **Instructor Dashboard:** A fully administrative interface for managing course groups, enrolling students, and analyzing class performance.
* **Student Portal:** A secure, email-based entry point where students can only access content explicitly assigned to their group, ensuring data privacy and relevant content delivery.

### 3. Complex Video Logic & DRM-like Controls
* **Granular Assignment:** Instructors can assign video content to the entire class or target specific students based on their unique IDs.
* **Time-Based Expiration Algorithm:** Implemented a custom expiration logic using `DateTime` calculations. Instructors set a validity duration (Days/Hours/Minutes), and the app automatically locks the content for the student once the timer expires.
* **Local File Handling:** Direct integration with the device file system to pick and play local video resources securely.

### 4. Academic Management Modules
* **Smart Attendance System:** An interactive, date-based attendance tracker that allows instructors to mark presence/absence and visualizes attendance rates dynamically per student.
* **Performance Tracking:** Dedicated fields for grading and private instructor notes per student, persisted locally.
* **Interactive Analytics:** Visual progress bars and statistical summaries for both students (video completion rates) and instructors (class statistics).

### 5. Reactive UI & UX
* **Dynamic Theming:** A robust `ThemeCubit` implementation allowing instant toggling between Dark and Light modes, persisting the user's preference automatically.
* **Micro-Interactions:** Polished UI with smooth list animations and transitions using `flutter_animate` to enhance user engagement.

---

## 🏗 Project Architecture

The codebase follows a strict **Feature-First** structure. Each feature module is fully self-contained with its own state management, data models, and UI screens, ensuring high modularity and scalability:

```text
lib/
├── core/
│   ├── theme/           # AppTheme definitions & ThemeCubit
│   └── widgets/         # Shared Reusable UI components
├── features/
│   ├── attendance/
│   │   ├── bloc/        # AttendanceBloc & Events
│   │   ├── models/      # Attendance Model
│   │   └── screens/     # AttendanceScreen
│   ├── course_management/
│   │   ├── bloc/        # GroupBloc
│   │   ├── models/      # CourseGroup Model
│   │   └── screens/     # Dashboard & Course Screens
│   ├── student_management/
│   │   ├── bloc/        # StudentBloc
│   │   ├── models/      # Student Model
│   │   └── screens/     # StudentList, Detail & Progress Screens
│   ├── video_management/
│   │   ├── bloc/        # VideoBloc (Timer & Logic)
│   │   ├── models/      # Video Model
│   │   └── screens/     # VideoControl & Player Screens
│   └── student_dashboard/
│       └── screens/     # StudentLogin & Dashboard Screens
└── main.dart            # App Entry Point & Bloc Provider Injection
