# Mandi Intelligence App 🌾📈

A robust, full-stack agricultural market intelligence application designed to analyze and track daily Mandi commodity prices. The system combines a powerful, robust **FastAPI (Python) backend** powered by an ORM database layout, with a highly interactive **Flutter (Dart) frontend** styled with smooth charts and state-of-the-art loaders.

## 📚 Technical Documentation

Complete technical documentation, architecture diagrams, database schemas, machine learning pipeline, API specifications, and workflow guides are available on the automated documentation website:

👉 **[View Technical Documentation Website](https://navaneeth832.github.io/mandi-intelligence-app/docs/)**

*(Note: The documentation site is generated automatically from `agent_helper.md` via GitHub Actions on every push to the `main` branch).*

---

## 🚀 Key Features

- **Real-time Price Indexing**: View minimum, maximum, and modal prices of agricultural produce.
- **Robust Multi-level Filtering**: Filter mandi prices by State, District, Market, Commodity, and Variety.
- **Advanced Visualization**: Interactive graphs and performance charts (using `fl_chart`) representing price fluctuations and insights.
- **Professional State Management**: Implemented using Riverpod (`flutter_riverpod`) to ensure reactive, robust, and decoupled business logic.
- **Pre-configured App States**: Built-in support for multiple interface states:
  - **Loading State** (styled with shimmering placeholder effects via `shimmer`).
  - **Success State** (rendered with interactive tables and charts).
  - **Empty State** (gracefully handles empty filters or no-data scenarios).
  - **Error State** (displays interactive errors to the user with retry capabilities).
- **Testing Controls**: Easy-to-use testing toggles to simulate all possible UI states (Loading, Error, Empty) on-demand.

---

## 🛠️ Technology Stack

### Backend
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python)
- **Database ORM**: [SQLAlchemy](https://www.sqlalchemy.org/)
- **Database Driver**: [psycopg2-binary](https://pypi.org/project/psycopg2-binary/) (supports PostgreSQL, easily configurable for SQLite/MySQL)
- **Environment Management**: `python-dotenv`
- **ASGI Web Server**: [Uvicorn](https://www.uvicorn.org/)

### Frontend
- **Framework**: [Flutter](https://flutter.dev/) (Dart SDK ^3.5.0)
- **State Management**: [Riverpod (flutter_riverpod)](https://riverpod.dev/)
- **Charting Engine**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Placeholders / Skeletons**: [shimmer](https://pub.dev/packages/shimmer)
- **Date / Format Utils**: [intl](https://pub.dev/packages/intl)
- **HTTP Client**: [http](https://pub.dev/packages/http)

---

## 📂 Project Structure

```text
mandi-intelligence-app/
├── backend/                   # FastAPI Backend
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/        # Router endpoints (mandi-prices, markets, states, etc.)
│   │   ├── core/
│   │   │   ├── config.py      # App configurations
│   │   │   └── database.py    # SQLAlchemy session & database engine setup
│   │   ├── models/            # SQLAlchemy database schemas/entities
│   │   ├── schemas/           # Pydantic validation schemas
│   │   └── main.py            # FastAPI Entry Point and Middleware initialization
│   ├── create_tables.py       # Table creation helper script
│   └── requirements.txt       # Python dependencies list
│
├── lib/                       # Flutter Frontend
│   ├── core/
│   │   ├── constants/         # Global API and theme constants
│   │   ├── theme/             # Global light/dark themes
│   │   └── utils/             # Helper utilities
│   ├── data/
│   │   ├── models/            # Dart Models (MandiPrice model and fromJson mapper)
│   │   ├── repositories/      # Repository implementation with simulator toggles
│   │   └── services/          # HTTP request handlers/API clients
│   └── features/
│       └── mandi_prices/      # Mandi Price core feature folder
│           ├── providers/     # Riverpod Providers & Filter State
│           ├── screens/       # Views (Home, FilterResults, MarketDetail)
│           └── widgets/       # Reusable components (Shimmers, charts, filters)
│
├── docs/                      # Technical Documentation & Architectural Specs
│   ├── api_contract.md        # API Request/Response contract standard
│   ├── app_states.md          # State management criteria
│   └── database_schema.md     # Mandi Prices DB Table structural details
│
├── pubspec.yaml               # Flutter/Dart package manager & assets mapping
└── README.md                  # Project configuration and setup guide
```

---

## ⚙️ Backend Setup & Configuration

Follow these steps to configure, set up, and run the FastAPI backend server.

### Prerequisites
- **Python 3.10 or higher** installed on your machine.
- A running **PostgreSQL** database (or any standard database supported by SQLAlchemy like **SQLite**).

### 1. Initialize Virtual Environment
Navigate to the `backend/` directory and create a virtual environment:

```bash
# Navigate to the backend folder
cd backend

# Create virtual environment (.venv)
python -m venv .venv
```

**Activate the virtual environment:**
- **On Windows (CMD / PowerShell):**
  ```powershell
  .venv\Scripts\activate
  ```
- **On macOS / Linux:**
  ```bash
  source .venv/bin/activate
  ```

### 2. Install Dependencies
Install all required Python dependencies:

```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables
Create a `.env` file in the `backend/` directory to manage database settings.

**Example for PostgreSQL:**
```env
DATABASE_URL=postgresql://username:password@localhost:5432/mandi_db
```

**Example for SQLite (Ideal for zero-setup local testing):**
```env
DATABASE_URL=sqlite:///./mandi.db
```

### 4. Create Database Tables
Run the schema initialization script to automatically construct all database tables using SQLAlchemy:

```bash
python create_tables.py
```
*Expected Output: `Tables created successfully!`*

### 5. Run the Backend Server
Launch the development server with Uvicorn (hot-reloading enabled):

```bash
uvicorn app.main:app --reload
```
- The backend API will be live at: **`http://127.0.0.1:8000`**
- Interactive Swagger API Documentation can be accessed at: **`http://127.0.0.1:8000/docs`**

---

## 📱 Frontend Setup & Configuration

Follow these steps to configure, build, and run the Flutter frontend.

### Prerequisites
- **Flutter SDK (version ^3.5.0)** installed and verified (`flutter doctor`).
- An active device (Android/iOS emulator, web browser, or native Desktop build targets).

### 1. Configure the API Endpoint
Ensure the frontend matches your backend local server URL. 
- Open `lib/data/services/mandi_api_service.dart`.
- Verify/Update the `baseUrl` property to point to your running FastAPI server (default is `http://127.0.0.1:8000`):

```dart
static const String baseUrl = 'http://127.0.0.1:8000'; // Update as needed
```

### 2. Install Package Dependencies
From the project root directory, run the following command to download all necessary Flutter packages:

```bash
flutter pub get
```

### 3. Build & Run the App
To run the application, select your target platform/device and execute:

```bash
flutter run
```
To run the app on a specific device, list your devices with `flutter devices` and use:
```bash
flutter run -d <device-id>
```

---

## 🧪 UI State Testing & Simulations

The application comes equipped with a **testing suite control system** to let engineers inspect and test different interface layouts easily without needing complex DB configurations.

To test how the Flutter app handles different states:
1. Open `lib/data/repositories/mandi_repository.dart`.
2. Locate the **TASK 5: TESTING CONTROLS** flags at the top of the file:

```dart
// TASK 5: TESTING CONTROLS
const bool simulateLoading = false;
const bool simulateError = false;
const bool simulateEmpty = false;
```

3. Toggle any of these flags to `true` (remember to set only one at a time for accurate simulation):
   - **`simulateLoading`**: Simulates a 10-second delay in network operations to demonstrate the shimmer loader screens.
   - **`simulateError`**: Forces the repository to throw a network exception to display the interactive error boundary screen.
   - **`simulateEmpty`**: Simulates a successful request returning 0 items, triggering the empty state screen.
4. Hot-reload or restart your Flutter application to see the state instantly represented in the UI.

---

## 📡 Core API Endpoints

Once your backend is running, the following endpoints are available:

- **`GET /`**: Welcome message and API info.
- **`GET /health`**: Endpoint monitoring the system health.
- **`GET /states`**: List of all states currently registered in the database.
- **`GET /commodities`**: List of all agricultural commodities.
- **`GET /markets`**: List of all physical Mandi markets.
- **`GET /mandi-prices`**: Core query engine. Supports the following optional parameters:
  - `state` (string)
  - `district` (string)
  - `market` (string)
  - `commodity` (string)
  - `variety` (string)

---

## 🤝 Contribution & Standards
Please adhere to the styling conventions outlined in `analysis_options.yaml` for Flutter, and write idiomatic FastAPI path operations on the backend. Always write proper models/schemas and avoid direct SQL manipulation when mapping new fields.
