# Autoplay Lab

This is a minimal, non-invasive automated playtesting system for the Life Sandbox Flutter prototype.

It runs headless simulations of the core game logic by utilizing the pure Dart domain services (e.g., `ActionService`, `MonthResolver`, `EventService`) directly, completely bypassing the Flutter UI.

## What is covered?
- **Month Progression:** Uses the exact same `MonthResolver` as the playable game.
- **Actions:** Bots can spend energy/cash on standard actions (Rest, Walk, Study, etc.).
- **Jobs:** Bots evaluate and apply to jobs utilizing the actual `ApplicationEvaluator`.
- **Education:** Bots can enroll and spend energy on self-improvement.
- **Company:** Bots can found companies and execute business actions.
- **Finance/Debts:** Bots passively accumulate debt/interest like a player and can actively take loans, open deposits, and pay down debt.
- **Housing:** Bots can make decisions to upgrade or downgrade housing based on their cash flow and stress.
- **Wellbeing:** The simulation properly tracks stress/health/happiness using `WellbeingService`.
- **Events:** The simulation pauses to force bots to resolve pending events before continuing, and bots dynamically evaluate event choices based on their unique policy.
- **Milestones:** The simulation synchronizes and evaluates milestone progress exactly like the main game via `ProgressionService`.
- **Seeds/Determinism:** Runs accept a deterministic seed for full reproducibility and safe bot variation testing.

## What is intentionally limited/left alone?
- **UI & Widgets:** Completely untouched. There are no UI-driving or automated taps.
- **Item/Shop Systems:** Bots are currently unaware of consumer purchases or asset management outside of basic finance tools.
- **State Persistence:** The simulation holds `GameState` purely in memory. It does not read or overwrite the player's saved game.

## How it works safely

No main-code changes were required in the `lib/` directory! The entire simulation was built on the premise that the existing game models and services are written as pure Dart functions taking in `GameState` and returning a new `GameState`. 

*Note: For Phase 2, `GameState` was safely extended to include a `randomSeed` variable to centralize the randomness used by `EventService` across the simulation, guaranteeing deterministic reproducability without affecting the player's UI experience.*

*For Phase 3, the `SimulationRunner` was updated to explicitly call `progressionService.syncMilestones(state)` after every state transition, ensuring milestone evaluation triggers exactly as it does in the main game's `GameController`.*

## Usage

You can run the simulation from the project root using standard Dart.

### Single Run
Runs a simulation with default settings (1 run, 24 months, mixed bots):
```bash
dart run autoplay_lab/bin/run_batch.dart
```

### Batch Runs & Configuration
You can pass arguments to control the simulation length, bot behavior, and seeds:

```bash
# Run 10 simulations of GrowthBot for 36 months with an explicit base seed
dart run autoplay_lab/bin/run_batch.dart --runs=10 --months=36 --bot=growth --seed=12345

# Replay a specific run for debugging
dart run autoplay_lab/bin/run_batch.dart --runs=1 --bot=survival --seed=12347
```

Available bots:
- `survival`: Prioritizes low stress, health, and debt payment. Highly penalizes event choices that increase stress or lower cash. Very safe, rarely moves housing.
- `growth`: Pursues education and promotion, willing to tolerate higher stress. Prefers event choices that offer intelligence or reliability.
- `company`: Immediately pushes for business creation and dumps all energy into operations. Prefers event choices that generate pure cash, despite the health consequences.
- `debt`: A true finance-pressure coverage bot. It takes formal loans to maintain flexibility, mistakenly locks up cash in deposits, downgrades housing when stressed, and scrambles to pay down debt when emergency debt triggers.
- `balanced`: Acts closer to a normal aspirational player. Seeks job stability, pursues education, upgrades housing when flush with cash, and transitions into company creation cautiously once a safety net is built.
- `pressure`: (PrecariousBot) A scenario-style bot that tests fragile loops. It seeks income but optimizes poorly, overextends on expensive housing early, delays recovery actions, takes loans instead of resting, and reveals if the game economy is too forgiving or too harsh on struggling players.
- `mixed`: (Default) Alternates between all 6 available bots if multiple runs are selected.

### Controlled Variation
When running in batch mode, runs utilize controlled variation. The bots use the `Random` object initialized by the run's seed to introduce slight heuristic variations (e.g., choosing a random equally viable education program, or doing a walk instead of a deep rest). This prevents batch runs from being identical clones while still respecting the bot's identity and remaining fully deterministic for that specific seed.

## Outputs
Outputs are saved as JSON files in `autoplay_lab/output/`.
- **Single Run Logs:** `single_run_<bot>_<seed>_<timestamp>.json` contains the full month-by-month snapshots, rich run diagnostic trackers (including counts of loans taken, deposits opened, paydowns, housing moves, and months spent under finance pressure), detailed coverage flags, and final state.
- **Batch Summaries:** `batch_summary_<bot>_<timestamp>.json` contains high-level aggregate metrics across the whole batch, plus a detailed `per_bot` breakdown allowing you to clearly compare how often different bot personas take formal loans, hit emergency debt, move housing, or struggle under finance pressure.
