# Student Assistant Application System
### TPG316C – Technical Programming III | GROUP ASSIGNMENT

---

## Group Members

| Student Number | Full Name     |
|----------------|---------------|
| 210070123      | John Doe      |
| 210070456      | Jane Smith    |
| 210070789      | Clark Kent    |
| 210070111      | Bruce Lee     |
| 210070222      | Diana Prince  |

---

## Project Overview

A Flutter mobile application that allows students to apply for **Student Assistant** positions at the IT Department, and allows admin staff to review, approve or reject applications.

Built with:
- **Flutter** (Dart) — UI framework
- **Supabase** — Authentication, PostgreSQL database, file storage
- **Provider** — State management (MVVM)
- **GitHub** — Version control

---

## Architecture: MVVM + Provider

```
lib/
├── main.dart                         # Entry point, Provider setup
├── app_router.dart                   # Named route navigation
├── models/
│   ├── profile_model.dart            # User profile data class
│   ├── module_model.dart             # Module data class
│   └── application_model.dart       # Application data class + status enum
├── viewmodels/
│   ├── auth_viewmodel.dart           # Login, register, sign-out logic
│   ├── application_viewmodel.dart    # Student CRUD operations
│   └── admin_viewmodel.dart          # Admin review operations
├── services/
│   └── supabase_service.dart         # All Supabase API calls
├── views/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── student/
│   │   ├── student_home_screen.dart
│   │   ├── application_form_screen.dart
│   │   └── application_detail_screen.dart
│   ├── admin/
│   │   ├── admin_dashboard_screen.dart
│   │   └── admin_application_detail_screen.dart
│   └── shared/
│       ├── splash_screen.dart
│       └── shared_widgets.dart
└── utils/
    ├── app_constants.dart            # Colors, text styles, theme, routes
    └── validators.dart               # Form field validators
```

---

## Setup Instructions

### 1. Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- A Supabase account (free tier is fine)

### 2. Clone the repository
```bash
git clone https://github.com/your-group/GROUP_A.git
cd GROUP_A
```

### 3. Set up Supabase
1. Go to [supabase.com](https://supabase.com) and create a new project.
2. Open the **SQL Editor** and run the entire contents of `supabase_schema.sql`.
3. In **Project Settings → API**, copy your **Project URL** and **anon public key**.

### 4. Configure environment variables
Edit the `.env` file in the project root:
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 5. Create an Admin account
After running the schema, register a user normally, then update their role in Supabase:
```sql
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'admin@example.com';
```

### 6. Install dependencies and run
```bash
flutter pub get
flutter run
```

### 7. Before submission – reduce file size
```bash
flutter clean
```
Then zip the project folder.

---

## Features

### Student Portal
- **Authentication** — Register / Login via Supabase Auth
- **Home Screen** — View submitted applications and their status
- **Application Form** — Apply for 1–2 modules with validation
- **Application Detail** — View full details, edit or delete (pending only)

### Admin Portal
- **Dashboard** — View all applications with status filter chips
- **Application Review** — Approve or reject with optional comments
- **Remove Application** — Delete invalid applications

### Supabase Backend
- Authentication with role-based access (student / admin)
- PostgreSQL tables: `profiles`, `modules`, `applications`
- Row Level Security (RLS) policies for data isolation
- Storage bucket for uploaded documents
- Triggers for `updated_at` timestamps and auto-profile creation

---

## Concepts Applied (Units 1–5)

| Unit | Concept | Where Applied |
|------|---------|---------------|
| 1 | Dart & Flutter basics | All screens, models |
| 2 | UI design & widgets | Custom theme, shared widgets |
| 3 | State management (MVVM + Provider) | All ViewModels |
| 4 | Navigation & routing | `app_router.dart`, named routes |
| 5 | Supabase Auth & CRUD | `supabase_service.dart`, ViewModels |

---

## GitHub Workflow

Each group member commits to a feature branch and opens a pull request:
```
main
├── feature/auth-screens
├── feature/student-portal
├── feature/admin-portal
├── feature/supabase-setup
└── feature/documentation
```
