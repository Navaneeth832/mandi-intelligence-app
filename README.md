# 🚜 Mandi Intelligence App 🌾📈

[![Live Website](https://img.shields.io/badge/Live%20API-website-brightgreen)](https://mandiintelligence.tech/)
[![Documentation](https://img.shields.io/badge/Technical%20Docs-documentation-blue)](https://mandiintelligence.tech/docs/)
[![Latest Release](https://img.shields.io/badge/GitHub-Releases-orange)](https://github.com/Navaneeth832/mandi-intelligence-app/releases/latest/download/app-release.apk)

An agricultural marketplace intelligence and price analysis platform designed to empower farmers, traders, and agricultural stakeholders across India. Mandi Intelligence provides real-time mandi prices, 7-day machine learning price forecasts, location-based mandi comparisons, and actionable price alerts.

---

## 📱 App Download & Live Links

- 🌐 **Live Hosted Backend API**: [https://mandi-intelligence-app.onrender.com](https://mandi-intelligence-app.onrender.com)
- 📚 **Technical Documentation**: [Documentation page](https://mandiintelligence.tech/docs/)
- 📦 **Latest GitHub Release APK**: [GitHub Releases](https://github.com/Navaneeth832/mandi-intelligence-app/releases/latest/download/app-release.apk)

### 📲 Scan to Download App (APK)

![App Download QR Code](https://github.com/Navaneeth832/mandi-intelligence-app/releases/latest/download/latest-release-qr.png)

> Scan the QR code above with your mobile device to download the latest Android APK directly from GitHub Releases.

---

## ✨ What This App Does

Mandi Intelligence bridges the information gap for agricultural markets by aggregating live prices, forecasting future trends, and calculating net selling profits across nearby mandis.

### Key Capabilities

- 📊 **Real-Time Mandi Prices**: Track daily arrival prices (modal, minimum, maximum) across states, districts, markets, and crop varieties with grade details.
- 🔮 **7-Day Machine Learning Forecasts**: Plan sales in advance using 7-day modal price trajectory forecasts, peak price predictions, and AI sell/hold recommendations (*Sell Today*, *Wait*, *Hold*).
- 🏬 **Best Markets & Variety Matching**: Discover top-paying mandis in your district or across India strictly matched to your crop's exact variety and grade.
- 📍 **Interactive Nearby Mandi Comparison**: Compare nearby mandis using GPS location detection or OpenStreetMap pin drops to evaluate net payouts and transport costs.
- 🔔 **Actionable Price Shift Alerts**: Receive real-time in-app, email, and push notifications for price increases, price drops, better market selling opportunities, and AI recommendations.
- 🌍 **Multi-Language Support**: Full UI and data localization in **English**, **Hindi (हिंदी)**, and **Malayalam (മലയാളം)**.
- ⚡ **Offline Resilience**: Instant zero-latency loading using local caching, allowing seamless operation even under poor rural network conditions.

---

## 📖 User Manual

### 1. Authentication & Onboarding
1. **Sign Up / Log In**: Register using your Email or Mobile Phone Number. Enter the 6-digit OTP received via email or SMS to verify your account.
2. **Profile & Location Setup**: Select your State, District, Preferred UI Language, and trackable crops.

### 2. Tracking Daily Prices (Home Screen)
- View current daily prices customized to your preferred crops and region.
- Use dropdown filters to quickly search prices by **State**, **District**, **Market**, or **Crop Variety**.
- Prices are ordered automatically based on your preferred market, district, state, and tracked crops.

### 3. Predictive Advisory & Best Markets (Advisory Tab)
- Select any of your tracked crops to inspect its 7-day price forecast trajectory.
- View the **AI Advisory Card** for recommendation insights (*Sell Today*, *Wait*, or *Hold*).
- Scroll down to **Best Markets** to see top-paying mandis in your district for that exact commodity, variety, and grade.
- Tap **Load Other Markets** to expand the list to top mandis across India for the same variety and grade.

### 4. Interactive Nearby Mandi Comparison
1. On any crop forecast screen, tap **Compare Nearby Mandis**.
2. Tap **Use Current Location (GPS)** or place a pin marker on the interactive map.
3. Tap **Compare Mandis for This Location** to view net payout comparisons, transport costs, and distance metrics.

### 5. Managing Alerts & Preferences
- Tap the **Notification Bell** in the top header to view active actionable price alerts.
- Filter alerts by type (*Price Increase*, *Price Drop*, *AI Recommendation*).
- Go to the **Profile Tab** to customize crop preferences, location, language, or notification delivery channels (In-App, Email, Push).

---

## 🛠️ Setup & Installation Guide

### Prerequisites
- **Flutter SDK**: `^3.5.0` or higher
- **Python**: `3.10+` or `3.12+`
- **PostgreSQL Database** (PostGIS enabled)

---

### Backend Setup (FastAPI)

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Navaneeth832/mandi-intelligence-app.git
   cd mandi-intelligence-app/backend
   ```

2. **Create & Activate Virtual Environment**:
   ```bash
   python -m venv .venv
   # On Windows PowerShell:
   .\.venv\Scripts\Activate.ps1
   # On macOS/Linux:
   source .venv/bin/activate
   ```

3. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure Environment Variables**:
   Create a `.env` file in the `backend/` directory:
   ```env
   DATABASE_URL=postgresql://user:password@localhost:5432/mandi_db
   SECRET_KEY=your_super_secret_jwt_key
   RESEND_API_KEY=your_resend_api_key
   FAST2SMS_API_KEY=your_fast2sms_api_key
   ```

5. **Run the FastAPI Development Server**:
   ```bash
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```
   API docs will be available at `http://localhost:8000/docs`.

---

### Frontend Setup (Flutter)

1. **Navigate to Project Root**:
   ```bash
   cd mandi-intelligence-app
   ```

2. **Install Flutter Packages**:
   ```bash
   flutter pub get
   ```

3. **Generate Localization Files**:
   ```bash
   flutter gen-l10n
   ```

4. **Run the Application**:
   ```bash
   # Run on Chrome / Desktop Frame:
   flutter run -d chrome

   # Run on Connected Mobile Device / Emulator:
   flutter run
   ```

---

## 📄 Documentation & Attribution

- 📚 **Full Architectural Blueprint**: For deep technical implementation details, database ER schemas, machine learning pipeline, alert engine, and API contracts, view [Documentation page](https://mandiintelligence.tech/docs/).
