# 🚨 Mandi Intelligence App: Full Service Audit, Expiration & Quota Management Report (4th September, 2026)

---

## 🗓️ Service Expiration & Critical Risk Timeline

The table below lists all active services, their exact expiration dates, current usage/quota states (extracted from your live dashboards), and immediate risk levels.

| Service | Component / Purpose | Expiration / Renewal Date | Current Status / Quota State | Risk Level |
| :--- | :--- | :--- | :--- | :--- |
| **Supabase (PostgreSQL)** | Primary App Database | **IMMEDIATE BREACH** | 🔴 **536 MB / 500 MB (OVER CAP)**<br>⚠️ Banner: *Grace period is over*<br>⚠️ Egress exceeded last month! | 🚨 **CRITICAL** (Imminent DB Lockout) |
| **Titan Business Email** | Webmail for `mandiintelligence.tech` | **Oct 3, 2026** *(35 Days Left)* | 🟡 **Free Trial Ending** (2 email accounts) | ⚠️ **HIGH** (Will revert to paid after trial) |
| **Render Web Service** | FastAPI Backend Hosting | **Ongoing (Free Tier)** | 🟡 750 hrs/mo free, 15-min auto-sleep.<br>Kept alive via Google Apps Script | 🟡 **MEDIUM** (Apps Script bandwidth overhead) |
| **Custom Domain** | `mandiintelligence.tech` | **Jul 12, 2027** | 🟢 Active, but **Auto-Renew is OFF** | 🟢 **LOW** (Safe until July 2027) |
| **Resend API** | Transactional Emails | **Ongoing (Free Tier)** | 🟢 48 emails sent, 95.83% deliverability.<br>Quota: 3,000/mo (100/day cap) | 🟢 **STABLE** |
| **Fast2SMS** | SMS Alerts | **Prepaid Balance** | 🟡 Subject to wallet balance & DLT rules | 🟡 **MONITOR** |
| **Firebase (FCM)** | Mobile Push Notifications | **Lifetime Free** | 🟢 Unlimited notifications | 🟢 **STABLE** |
| **Data.gov.in API** | Mandi Price Feed Source | **Lifetime Free API Key** | 🟢 Free Govt quota | 🟢 **STABLE** |
| **GitHub Pages & Actions** | Tech Docs & CI/CD | **Lifetime Free** | 🟢 2,000 free build mins/mo | 🟢 **STABLE** |

---

## 🛠️ Deep-Dive Service Analysis & Zero-Cost Resolution Protocols

---

### 1. 🚨 Supabase PostgreSQL Database (Immediate Critical Action Required)

#### 🔴 The Problem Identified from Dashboard
* **Database Size**: **536 MB / 500 MB** (You are **36 MB over the free limit**!). Supabase has displayed the warning banner: `Grace period is over - Your projects will not be able to serve requests when you use up your quota`.
* **Last Month Egress Breach**: Querying large unfiltered mandi price records caused outbound network transfer (Egress) to exceed the free 5 GB limit. Current cycle egress is at 1.87 GB / 5 GB.

#### 💡 Zero-Cost Resolution Protocols
1. **Clean Up Historical / Duplicate Mandi Records (Immediate DB Shrink)**:
   Run the following SQL queries directly in the **Supabase SQL Editor** to clean unneeded logs and reclaim disk space:
   ```sql
   -- 1. Identify table sizes
   SELECT pg_size_pretty(pg_total_relation_size(relid)) AS total_size, relname
   FROM pg_catalog.pg_statio_user_tables
   ORDER BY pg_total_relation_size(relid) DESC;

   -- 2. Delete outdated daily price logs or temporary scrap runs older than 90 days
   DELETE FROM mandi_prices 
   WHERE arrival_date < CURRENT_DATE - INTERVAL '90 days';

   -- 3. Reclaim unused disk space back to OS (Crucial step!)
   VACUUM FULL;
   ```
2. **Prevent Egress Spikes (Query Optimization)**:
   * Do **NOT** run `SELECT * FROM mandi_prices` without limit/pagination.
   * Update FastAPI endpoints (`/v1/mandi-prices`) to default to pagination (`limit=50`, `offset=0`) and select only essential columns (e.g., `state`, `district`, `market`, `commodity`, `modal_price`, `arrival_date`).
3. **Alternative Zero-Cost Backup Database**:
   * If database growth cannot be reduced under 500 MB, spin up a free PostgreSQL instance on **[Neon.tech](https://neon.tech)** (0.5 GiB storage with branch isolation & autosuspend) or **[Render PostgreSQL Free Tier](https://render.com)**, or create a second free organization on Supabase and migrate tables via `pg_dump`.

---

### 2. ⚠️ Titan Business Email (`mandiintelligence.tech`)

#### 🟡 The Problem Identified from Dashboard
* The email service hosted via Hostinger for `mandiintelligence.tech` is a **35-Day Free Trial** ending on **October 3, 2026**.
* After October 3, 2026, Titan will require a paid subscription (~$2–$3/user/month).

#### 💡 Zero-Cost Resolution Protocols
1. **Do NOT Pay for Titan Business Email**:
   Cancel or ignore the Titan trial upgrade prompt before Oct 3, 2026.
2. **Switch FastAPI Email Backend to Resend API or Free Gmail SMTP**:
   * You are already successfully using **Resend** for transactional emails (48 emails sent, 95.83% deliverability as shown in your dashboard screenshot). Resend provides **3,000 free emails per month**.
   * Alternatively, configure FastAPI's `SMTP_HOST` in [`backend/app/core/config.py`](file:///c:/Users/HP/Desktop/Projects/2026%20summer%20projects/mandi-intelligence-app/backend/app/core/config.py#L7-L11) to use a free Gmail address with an **App Password**:
     ```env
     SMTP_HOST=smtp.gmail.com
     SMTP_PORT=587
     SMTP_EMAIL=your_app_email@gmail.com
     SMTP_PASSWORD=your_16_char_google_app_password
     ```

---

### 3. ⚡ Render Backend & Google Apps Script Ping Mechanism

#### 🟡 The Problem & Apps Script Interaction
* Render's Free Web Service enters a **cold-start sleep mode after 15 minutes of inactivity**.
* You have implemented a **Google Apps Script** (e.g., `UrlFetchApp.fetch("https://mandi-intelligence-app.onrender.com/v1/health")`) to periodically ping the backend and keep it awake.
* **Side Effect**: Pinging too frequently (e.g., every 1–2 minutes) unnecessarily consumes Render outbound bandwidth and causes database queries to continuously execute against Supabase, contributing to database egress spikes!

#### 💡 Zero-Cost Resolution Protocols
1. **Optimize Apps Script Trigger Frequency**:
   Set your Google Apps Script trigger to execute **every 12 to 14 minutes** (instead of every 1–5 minutes). This is the exact optimal threshold to prevent Render from sleeping while reducing bandwidth & DB traffic by up to 80%.
2. **Ensure Light Health Endpoint**:
   Ensure `/v1/health` in FastAPI returns a simple JSON static response `{"status": "ok"}` **without querying the Supabase database**:
   ```python
   @router.get("/health")
   def health_check():
       return {"status": "healthy"}
   ```

---

### 4. 🌐 Custom Domain (`mandiintelligence.tech`)

#### 🟢 Current Status
* Expiration Date: **July 12, 2027** (Safe for ~10 months).
* **Auto-Renew**: Currently **OFF**.

#### 💡 Zero-Cost Resolution Protocols
1. Since the internship company has not provided a budget, do not turn on auto-renew with your personal credit card.
2. If the company does not renew the domain before July 2027, update your Flutter app's [`api_constants.dart`](file:///c:/Users/HP/Desktop/Projects/2026%20summer%20projects/mandi-intelligence-app/lib/core/constants/api_constants.dart#L3) back to the free fallback Render domain:
   ```dart
   static const String baseUrl = 'https://mandi-intelligence-app.onrender.com';
   ```

---

### 5. 📱 Fast2SMS vs. Firebase FCM (Push Notifications)

#### 🟡 SMS Cost Warning
* **Fast2SMS** requires prepaid cash top-ups per SMS sent.

#### 💡 Zero-Cost Resolution Protocols
1. Transition all price alerts, daily mandi updates, and security alerts to **Firebase Cloud Messaging (FCM)** via [`push_notification_service.dart`](file:///c:/Users/HP/Desktop/Projects/2026%20summer%20projects/mandi-intelligence-app/lib/core/services/push_notification_service.dart).
2. Firebase FCM is **100% free with unlimited push notifications**, eliminating SMS costs entirely.

---
