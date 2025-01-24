# Movely Project Documentation
- **Lutziger**
- **Cyril**

| Date     | Version | Summary                                                                                              |
|----------|---------|------------------------------------------------------------------------------------------------------|
| 24.01.25 | 0.0.1   | Created Movely Flutter project and initial project structure.                                        |
| 31.01.25 | 0.0.2   | Designed initial UI/UX prototype and authentication flow.                                            |
| 07.02.25 | 0.0.3   | Implemented activity tracking and GPS route logging.                                                 |
| 14.02.25 | 0.0.4   | Developed streak system and basic social features.                                                   |
| 21.02.25 | 0.0.5   | Added user profile and activity analytics.                                                           |
| 28.02.25 | 0.0.6   | Integrated push notifications and leaderboard features.                                              |
| 07.03.25 | 0.1.0   | Completed MVP with core functionalities.                                                             |

## 1. Project Overview

### 1.1 Movely
Movely is a fitness tracking app combining Duolingo's streak system, Adidas Running's tracking, and Instagram's dark mode UI. The focus is on motivating users through social features with minimal data usage.

### 1.2 User Stories

| US-№ | Priority | Type            | Description                                                                                           |
|------|----------|-----------------|-------------------------------------------------------------------------------------------------------|
| 1    | Must     | Functional      | Create account with email and OTP verification.                                                       |
| 2    | Must     | Functional      | Track steps with motion sensor data.                                                                  |
| 3    | Must     | Functional      | Implement daily streak system with rewards.                                                           |
| 4    | Must     | Functional      | Create friend connections.                                                           |
| 5    | Should   | Functional      | Share activity statistics.                                                                            |
| 6    | Could    | Functional      | Customize user profile with achievements.                                                             |
| 7    | Must     | Quality         | Maintain minimal data usage and battery consumption.                                                  |
| 8    | Must     | Security        | Encrypt user GPS and personal data.                                                                   |
| 9   | Could    | Non-functional  | Support iOS/Android deployments.                                                                      |

### 1.3 Technical Stack

- **Frontend**: Flutter
- **Backend**: Supabase
- **Authentication**: Supabase Auth
- **Database**: PostgreSQL Supabase

## 2. Project Planning

| Arbeitspaket | Zeitrahmen | Beschreibung                                        | Geplante Zeit |
|--------------|------------|-----------------------------------------------------|---------------|
| Day 1        | 10.01.25   | Entwicklungsumgebung einrichten, Projektstruktur    | 180'          |
| Day 2        | 17.01.25   | Benutzerauthentifizierung mit OTP                   | 180'          |
| Day 3        | 24.01.25   | GPS-Tracking und Bewegungssensor-Integration        | 240'          |
| Day 4        | 31.01.25   | Streak-System Implementierung                       | 150'          |
| Day 5        | 07.02.25   | Soziale Funktionen und Leaderboards                 | 210'          |
| Day 6        | 14.02.25   | Integration, Tests, Fehlerbehebung                  | 180'          |
| Day 7        | 21.03.25   | Finale Dokumentation und Portfoliovorbereitung      | 120'          |

Total: 1260'

## 3. Implementation Status

| Arbeitspaket | Datum     | Geplante Zeit | Tatsächliche Zeit | Status      |
|--------------|-----------|---------------|-------------------|-------------|
| Day 1        | 24.01.25  | 180'          | 195'              | Completed   |
| Day 2        | 31.01.25  | 180'          | 190'              | Completed   |
| Day 3        | 07.02.25  | 240'          | 250'              | Completed   |
| Day 4        | 14.02.25  | 150'          | 160'              | Completed   |
| Day 5        | 21.02.25  | 210'          | 220'              | Completed   |
| Day 6        | 28.02.25  | 180'          | 190'              | Completed   |
| Day 7        | 07.03.25  | 120'          | 130'              | Completed   |

## 4. Test Report

| TC-№ | Test Status | Remarks                                           |
|------|-------------|---------------------------------------------------|
| 1-4  | Pass        | Core functionalities working as expected          |
| 5    | Partial     | Social sharing needs refinement                   |
| 6-8  | Pass        | Profile, performance, and security features solid |
| 9    | Partial     | Contact sync requires further testing             |
| 10   | Pending     | Cross-platform compatibility testing             |

## 5. Risk Analysis

- **Data Privacy**: Ensuring user data protection
- **Performance**: Maintaining low resource consumption
- **Social Features**: Creating engaging interactions

**Overall Project Risk**: Low

## 6. Personal Goals

1. GPS-Routenverfolgung und Bewegungssensorintegration
2. Implementierung eines motivierenden Streak-Systems
3. Entwicklung sozialer Funktionen

## 7. Future Roadmap

- Advanced activity analytics
- Offline tracking capabilities
- Health platform integration
