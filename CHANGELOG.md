# Changelog

All notable changes to this project will be documented in this file.

## [1.4.3] - 2026-02-13

### Added
- **Recurring Transaction Editing**: Full support for modifying existing recurring transactions directly from the automation list.
- **Enhanced Test Suite**: Added comprehensive unit tests for recurring transactions and resolved flakiness in navigation tests (`LockScreen`, `IntroScreen`).

## [1.4.2] - 2026-02-12

### Added
- **UI Polish**: Minor visual refinements across settings and navigation headers.
- **Stability**: Addressed timeout issues in widget testing suite.

## [1.4.1] - 2026-02-11

### Added
- **Payment History Enhancements**
  - **Credit Card History**: Full payment history tracking for all credit cards.
  - **Auto-Recording**: Automatic ledger entries when credit card bills are recorded as paid.
  - **Show-All Limit**: Optimized history lists that show only the 10 most recent payments by default with a "Show All" expansion toggle (for both Loans and Credit Cards).
  - **Demo Seeding**: Enhanced sample data seeding for better roadmap and history testing.

## [1.4.0] - 2026-02-09

### Added
- **Wealth Management (Phase 6)**
  - **Net Worth Tracking**: Historical evolution with asset/liability breakdown.
  - **Retirement Dashboard**: EPF/NPS tracking with corpus projections.
  - **Enhanced Portfolio**: Asset allocation charts and category management.
  - **Goal Milestones**: Progress tracking with celebratory completion feedback.
- **Intelligence & Automation (Phase 7)**
  - **Automation Engine**: Recurring income/expense processing based on calendar.
  - **Debt Payoff Planner**: Snowball/Avalanche simulators with interest savings.
  - **Advanced Bill Calendar**: Interactive month view with payment status.
  - **Centralized Hub**: "More" menu for managing all advanced strategy tools.
- **Polish & Scale (Phase 8)**
  - **Export Enhancements**: PDF/CSV reporting with custom date ranges.
  - **Adaptive UI**: Refined layouts for tablets and foldables.

### Fixed
- Fixed integration test failures.
- Improved Android build reliability.
- Refined credit card display and utilization tracking.
- Fixed notification scheduling for daily reminders.
- Resolved Windows notification repeating issues.
- Fixed payment calendar status accuracy for future bills.
- Improved performance and stability across platforms.
