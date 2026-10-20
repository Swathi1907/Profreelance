# ProFreelance (Flutter)

Freelance Project Intelligence and Contract Manager. A Flutter port of the Kotlin app in
`saadhana252007/ProFreelance`, with the same maroon / gold / cream identity, plus the nine
agreed features and a project-first workflow.

## Run it

```bash
unzip profreelance_app.zip && cd profreelance_app
flutter create --platforms=android,ios,web,windows .   # adds the platform folders
rm -f test/widget_test.dart
flutter pub get
flutter run -d chrome        # laptop layout (side navigation)
flutter run                  # phone or emulator (bottom navigation)
```

Flutter 3.27 or newer. Fonts come from Google Fonts, so the first run needs internet.
Demo login: any email and a password of 6+ characters (the form is pre-filled).

## Layout rules

| Width | Navigation |
| --- | --- |
| under 700px (phone) | bottom bar: Dashboard, Projects, Contracts, Payments, More |
| 700-1100px | icon rail |
| over 1100px (laptop) | full side bar |

## Flow

Dashboard (overall progress and client experience) → Projects → pick a project →
**project workspace** with Overview, Contract, Payments, Files and Negotiate tabs.
Clients works the same way: overall client experience first, then pick a client.

## The nine features

| Feature | Where | How it works |
| --- | --- | --- |
| New contract generation | Contracts, or project > Contract | 5-step wizard (about 45 inputs), 20+ clauses each with a reason, then a self-check by the analyser |
| Client contract analysis | Contracts, or project > Contract | clause extraction, keyword classifier, weighted risk lexicon, missing-term checklist, plain-English fixes |
| Amendment | project > Contract > Amend | 4-step change request, priced from similar past projects plus explicit technical adjustments |
| Payments and milestones | Payments, project > Payments | milestones tied to clauses, paid/pending/overdue, reminders, cash-flow chart |
| Performance analytics | Insights | estimation accuracy, bias, duration, earnings, technology and domain frequency |
| Smart alerts | Alerts | deadlines, payments, contract changes, scope creep, estimate drift |
| Client reliability | Clients | weighted sub-scores with recency decay and Bayesian shrinkage |
| Document vault | Vault, project > Files | categories, project links, tags, search, simulated encrypted upload |
| Negotiation assistant | Negotiate, project > Negotiate | intent detection plus deterministic counter-offers and a draft reply |

## Architecture (MVVM)

```
lib/
  core/        theme, widgets, utils, BaseViewModel
  data/        models, repositories (state holders), seed data, catalogs
  domain/      services: estimation, scoring, contracts, analysis, alerts, negotiation, analytics
  features/<name>/
    view/        widgets only, no logic
    viewmodel/   ChangeNotifier ViewModels: UI state and commands
  navigation/  adaptive shell and router
```

View → ViewModel → Repository → seed data (replace with Supabase). Services are pure Dart
and unit-testable. The Kotlin app already uses Supabase, so each repository method maps to
a table or storage call. See `lib/domain/services/*` for where trained models plug in.

## Prototype limits

Data lives in memory and resets on restart. The ML parts are baseline algorithms (kNN, lexicon
classifier, Bayesian scoring) with interfaces ready for trained models. PDF text extraction and
file upload are simulated.
