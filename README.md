FMAS Flutter App
================

A cross‐platform Flutter application for **Flood Monitoring and Alert System (FMAS)**, rebuilt from the original React frontend.It provides real-time flood alerts, user subscriptions, community reporting, and an admin dashboard — all powered by a Node.js/Express backend.

📝 Table of Contents
--------------------

*   [About FMAS](#-about-fmas)
    
*   [Features](#-features)
    
*   [Architecture & Technologies](#-architecture--technologies)
    
*   [Getting Started](#-getting-started)
    
    *   [Prerequisites](#prerequisites)
        
    *   [Installation](#installation)
        
    *   [Running the App](#running-the-app)
        
*   [Project Structure](#-project-structure)
    
*   [Routing & Navigation](#-routing--navigation)
    
*   [State Management](#-state-management)
    
*   [API Integration](#-api-integration)
    
*   [Screens & Widgets](#-screens--widgets)
    
*   [Assets & Styling](#-assets--styling)
    
*   [Testing](#-testing)
    
*   [Contributing](#-contributing)
    
*   [License](#-license)
    

📌 About FMAS
-------------

FMAS (Flood Monitoring and Alert System) empowers at-risk communities with **real-time** flood alerts, interactive maps, and local reporting. The system:

*   **Monitors** river sensors & satellite data
    
*   **Delivers** SMS/E-mail warnings
    
*   **Allows** community flood reporting
    
*   **Provides** an administration dashboard
    

This Flutter app is a one-to-one port of the existing React web client, optimized for mobile (Android/iOS) and desktop/web.

🚀 Features
-----------

*   **User Authentication**: Email/password + Google OAuth
    
*   **Subscription**: SMS & email flood alert subscriptions
    
*   **Home Screen**: Hero, features, impact stats, “Stay Updated” form
    
*   **Resources**: Downloadable guides & handbooks
    
*   **Donate**: Multiple donation options, partner programs
    
*   **Admin Dashboard**: Create/modify alerts, view subscriptions & reports
    
*   **Community Reporting**: Submit & view flood reports with images
    
*   **Active Alerts**: Filter by type, severity, time range, location
    
*   **FAQ & Contact**: Help center and feedback form
    

🏗 Architecture & Technologies
------------------------------

*   **Flutter** (Dart)
    
*   **State Management**: Riverpod
    
*   **Navigation**: [go\_router](https://pub.dev/packages/go_router)
    
*   **HTTP & API**: dio or http for REST calls
    
*   **Authentication**: JWT + secure storage
    
*   **Geolocation**: geolocator
    
*   **Charts & Animations**: recharts, \[framer\_motion\_flutter\] (optional)
    
*   **Styling**: Tailwind-inspired utility with \[flutter\_tailwind\_v4\] (optional)
    
*   **Assets**: SVGs via \[flutter\_svg\], fonts via \[google\_fonts\]
    

🛠 Getting Started
------------------

### Prerequisites

*   Flutter SDK ≥ 3.7.0
    
*   Dart ≥ 2.18.0
    
*   Android Studio / Xcode for mobile emulators
    
*   Node.js + Express backend running locally (see /backend folder)
    

### Installation

1.  bashCopyEditgit clone https://github.com/YourUsername/fmas\_flutter\_app.gitcd fmas\_flutter\_app
    
2.  bashCopyEditflutter pub get
    
3.  **Configure** environment
    
    *   Copy lib/config/env.sample.dart → lib/config/env.dart
        
    *   Set your API\_BASE\_URL, OAuth client IDs, etc.
        

### Running the App

*   bashCopyEditflutter run
    
*   bashCopyEditflutter build apk # Androidflutter build ios # iOSflutter build web # Web
    

📁 Project Structure
--------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   graphqlCopyEditlib/  ├── api/               # FmasApi: REST client skeleton  ├── config/            # Environment variables (API URLs, keys)  ├── models/            # Data classes (User, Alert, Report, etc.)  ├── providers/         # Riverpod state notifiers & providers  ├── screens/           # UI screens (auth, home, dashboard, etc.)  │   ├── auth/  │   ├── home/  │   ├── dashboard/  │   ├── alerts/  │   └── ...  ├── widgets/           # Reusable UI components (Navbar, Footer)  └── main.dart          # App entrypoint (ProviderScope + GoRouter)   `

🔀 Routing & Navigation
-----------------------

*   **main.dart** wraps ProviderScope and configures **GoRouter** with:
    
    *   Public routes: /login, /register
        
    *   Protected routes (guarded by authProvider.isAuthenticated): /, /about, /contact, /faq, /donate, /resources, /dashboard/\*
        
*   **app\_shell.dart** hosts the drawer/sidebar and wraps all dashboard sub-routes.
    

🌐 State Management
-------------------

We use **Riverpod** for:

*   **authProvider**: holds User? and isAuthenticated
    
*   **alertsProvider**, **reportsProvider**, **resourcesProvider**: async data‐fetching
    

Providers live in lib/providers, with corresponding data models in lib/models.

🔗 API Integration
------------------

*   dartCopyEditFuture login(String email, String password);Future loginWithGoogle(String idToken);Future register(RegisterData data);Future\> fetchActiveAlerts({ String? location, ... });Future\> fetchCommunityReports();// ...
    
*   All network logic lives here; providers call these methods and expose state to UI.
    

🖥 Screens & Widgets
--------------------

*   **Auth** (login\_screen.dart, register\_screen.dart)
    
*   **Home** (home\_screen.dart)
    
*   **About** (about\_screen.dart)
    
*   **Contact** (contact\_screen.dart)
    
*   **FAQ** (faq\_screen.dart)
    
*   **Donate** (donate\_screen.dart)
    
*   **Resources** (resources\_screen.dart)
    
*   **Dashboard** (admin\_dashboard.dart, user\_dashboard.dart)
    
*   **Alerts** (active\_alerts\_screen.dart, admin\_alerts\_screen.dart)
    
*   **Community Reports** (community\_reports\_screen.dart)
    

Each screen uses NavbarWidget (AppBar) and FooterWidget (bottomBar) for consistent layout.

🎨 Assets & Styling
-------------------

*   **Images**: place under assets/images/ and declare in pubspec.yaml.
    
*   **SVG icons**: flutter\_svg package.
    
*   **Fonts**: use google\_fonts for Roboto / Open Sans.
    
*   **Theme**: defined in main.dart via ThemeData.from(colorScheme).
    

✅ Testing
---------

*   **Unit Tests**: test/ folder for providers & API mocks
    
*   **Widget Tests**: simple smoke tests in test/widgets/
    
*   **Integration Tests**: use flutter drive (optional)
    

🤝 Contributing
---------------

1.  Fork the repository
    
2.  Create a feature branch (git checkout -b feature/awesome)
    
3.  Commit your changes (git commit -m "feat: add widget")
    
4.  Push to your branch (git push origin feature/awesome)
    
5.  Open a Pull Request
    

Please follow the Flutter style guide.

📄 License
----------

This project is licensed under the MIT License.