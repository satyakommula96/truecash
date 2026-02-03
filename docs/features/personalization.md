# Phase 5: Personalization Without Creep
**Goal: Adaptive Utility (reduce effort, preserve agency)**

> **Core Principle**  
> The app adapts to reduce effort — never to predict, judge, or manipulate behavior.  
> All personalization is **local, explainable, optional, and reversible**.

---

## Phase 5.1: Zero Risk (Foundations)

### Last-Used Memory
- Default to last used:
  - Category
  - Payment method
  - Merchant (if applicable)
- Always visibly surfaced in UI  
  - Example: *“Using last category: Food”*
- Must be manually overridable every time.

### Quick-Add Presets (User-Created)
- Users can pin common amount + category combos.
  - Examples:
    - `₹120 · Coffee`
    - `₹80 · Bus`
- Presets are:
  - Explicitly created by the user
  - Editable
  - Deletable
- No automatic creation of presets.

### Explicit Preferred Reminder Time
- User-selectable reminder time.
- Clear **“Off”** option.
- No default assumptions.
- No “smart guessing” of reminder time.

---

## Phase 5.2: Gentle Adaptation (High Friction by Design)

### Time-of-Day Defaults
- Suggest (never auto-save):
  - Morning → Breakfast / Commute
  - Evening → Dinner
- Enabled only after:
  - ≥ 5 similar entries
  - Same category
  - Same ~2-hour time window
  - Observed over ≥ 14 days
- Requires explicit tap to confirm.
- If repeatedly overridden → suggestion disabled.

### Salary Cycle Awareness
- One-time, explicit prompt:
  - *“When do you usually get paid?”*
- Used only for:
  - Budget cycle reset
  - Forecast framing (“until next salary”)
- Never used to infer income.
- Fully editable later.

### Shortcut Suggestions
- Micro-prompt after clear repetition:
  - *“You often log ‘Coffee’ as Food. Save as shortcut?”*
- Rules:
  - Shown once per pattern
  - Dismissable
  - “Don’t show again” available
- Never auto-create shortcuts.

### Suggestion Cooldown (Mandatory)
- If user dismisses a suggestion:
  - Suppress for 30 days
- If user selects “Don’t show again”:
  - Permanently disabled for that suggestion

---

## Phase 5.3: Trust & Control (Non-Negotiable)

### Transparency: “Why am I seeing this?”
- Available for **every adaptive suggestion**
- Example explanations:
  - *“Based on your last 6 evening entries”*
- If logic cannot be explained → feature must not exist.

### Reset Personalization
- One-click action:
  - *“Reset suggestions & defaults”*
- Clears:
  - Learned patterns
  - Adaptive defaults
- Does **not** delete transactions or user data.

### Per-Feature Personalization Toggles
- Fine-grained controls in Settings:
  - ☐ Remember last-used values
  - ☐ Time-of-day suggestions
  - ☐ Shortcut suggestions
- Global reset does **not** override explicit opt-outs.

### Personal Baseline Reflections (UI-Only)
- Compare user **only to themselves**
- Examples:
  - *“Higher than your usual Friday”*
  - *“Lower than your typical week”*
- Rules:
  - Minimum 3 weeks of data required
  - Never pushed as notifications
  - No emotional or judgmental language

---

## Data & Privacy Guarantees
- All personalization data is:
  - Stored locally on device
  - Never synced
  - Never uploaded
- No cross-user comparisons
- No profiling or hidden inference

---

## Explicitly Out of Scope
- Auto-categorization without confirmation
- Emotional or behavioral labeling
- Spending scores or rankings
- Cross-user or percentile comparisons

---

## Success Criteria
- Fewer taps to add transactions
- No increase in notification fatigue
- Users understand *why* suggestions appear
- Users can disable or reset personalization at any time
