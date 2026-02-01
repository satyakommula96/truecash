# Product Success Roadmap (TrueLedger)

This roadmap focuses on features that drive **retention, trust, and habit formation**.
We implement these phases sequentially.

## Phase 1: Retention (Goal: Daily Usage Hook)

- [x] **"Today" Screen / Widget on Dashboard**
    - [x] Show today's total spend (large, bold).
    - [x] Show remaining budget for today (if applicable) or month.
    - [x] Simple daily summary text: "You've spent ₹820 today."

- [x] **One-Tap Expense Entry**
    - [x] Floating Action Button (FAB) visible on Dashboard.
    - [x] Simplified "Quick Add" dialog:
        - [x] Amount keypad opens immediately.
        - [x] Category defaults to last used or "General".
        - [x] "Save" button is easily reachable.
        - [x] No full-screen navigation for quick entry.

- [x] **Budgets (Core Value)**
    - [x] Create `Budget` model (Category-based).
    - [x] "Add Budget" screen (Amount per Category).
    - [x] Visual progress bars on a dedicated "Budgets" tab.
    - [x] Colors: Green (Safe), Yellow (>75%), Red (>100%).

- [x] **Smart Reminders**
    - [x] "Daily Log" reminder (e.g., at 9 PM) *only if* no transaction added today.
    - [x] Budget proximity warning notification.

## Phase 2: Trust (Goal: Reliability & Correction)

- [x] **Search & Edit**
    - [x] Search bar in Transactions list (Amount, Category, Note).
    - [x] Edit/Delete capabilities for existing transactions.
    - [x] Undo option for deletions.

- [x] **Backup & Restore**
    - [x] Encrypted JSON Export/Import.
    - [x] Auto-backup to local file (Desktop/Mobile).
    - [x] Web browser download support.

- [x] **Web Support**
    - [x] Full responsive dashboard.
    - [x] SQLite WASM persistence.

- [x] **Weekly/Monthly Insights**
    - [x] "You spent 12% more than last week" (Plain text insights).
    - [ ] "Food is your top expense this month".

## Phase 3: Delight (Goal: Polish & Engagement)

- [x] **Streaks**
    - [x] "Daily Streak" counter on Dashboard.
    - [x] Confetti animation for hitting streak milestones.

- [ ] **Performance Polish**
    - [ ] Ensure app opens < 1s.
    - [ ] Optimistic UI updates (don't wait for DB to update UI).

---

## What NOT to build (Yet)
- Bank Sync
- AI Categorization
- Multi-currency complexity
- Social Sharing
