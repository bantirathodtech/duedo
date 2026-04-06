# 🚀 Duedo: Debt Tracker & Planner

**Take control of your financial freedom.** Duedo is a premium, AI-powered tool designed to help you track debts, plan growth, and visualize your journey to a debt-free life.

---

## 💎 Features

*   **Financial Freedom Dashboard**: A high-fidelity overview of your total debt and payoff progress.
*   **AI Predictor**: Smart algorithms that compute your estimated "Freedom Date" based on current repayment behavior.
*   **Multi-Goal Tracking**: Not just for debts! Personalize your journey with growth goals like education (e.g., Product Manager courses), savings, and more.
*   **Cloud Synchronization**: Secure, anonymous cloud backup powered by Supabase.
*   **Encrypted Local Database**: Fast and secure local-first experience with Drift persistent storage.
*   **Premium Edge UI**: A stunning, responsive dark-mode interface with glassmorphism and smooth micro-animations.

---

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (v3.10+)
*   **Backend**: [Supabase](https://supabase.com) (Anonymous Auth & Cloud Sync)
*   **Local Database**: [Drift](https://drift.simonbinder.eu) (SQLite for Flutter)
*   **Theme Engine**: Custom Material 3 with Google Fonts (Outfit & Inter)

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK
- Android Studio / VS Code
- A valid Supabase Project URL & Anon Key (configured in `lib/services/supabase_service.dart`)

### Installation
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/bantirathodtech/duedo.git
    cd duedo
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 📦 Production & Deployment

Duedo is optimized for Google Play deployment.
- **Signed App Bundle**: Configured with `key.properties` (ignored in Git).
- **Pro Features**: Integrated with Ad-Gate screen and subscription logic.
- **Proguard/R8**: Enabled for code shrinking and security.

---

## 🛡️ License & Privacy
Duedo is developed with user privacy as a core value. All financial data is encrypted and synced anonymously.
Built for the **Avishio** ecosystem.
