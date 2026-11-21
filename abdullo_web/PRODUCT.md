# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

The owner of a small business in Tajikistan with several stores (2–5), for example a cosmetics
shop chain such as "Kosmetika". They check sales, pay staff salaries, record expenses and set
sales targets. They work from a laptop in the office or a phone on the go, and they may think
and ask in Tajik, Russian or English.

## Product Purpose

Apex Suite puts the whole business in one place: stores, daily sales, employees, salary
payments, expenses, profit, sales targets, notifications and an activity log. An AI assistant
answers questions about the owner's own numbers. Success means the owner knows how the business
is doing today, who still needs to be paid, and where profit comes from, without spreadsheets
or a paper ledger.

## Positioning

What it offers that Excel, 1C or a paper ledger do not:
- **Everything in one place.** One panel for stores, sales, payroll, expenses and profit,
  served to the web (this project) and the mobile app from the same backend.
- **An AI that answers in Tajik.** The owner asks in their own language (tg / ru / en), and the
  assistant answers from the business's real figures, not general advice.
- **Automatic payroll.** Salary due, paid and unpaid amounts are calculated per employee and
  month, and overdue salaries raise notifications.
- **Built for Tajikistan.** Tajik, Russian and English throughout, with money in somoni (TJS)
  and an optional USD view at the server's exchange rate.

## Operating Context

- Team: Abdullo (web, this folder), Subhon (mobile app), Mehroj (backend, FastAPI on Railway).
- Data comes only from Mehroj's API (contract in the repo-root `API.md`). The web never invents
  data.
- Daily rhythm: record the day's sales per store, check the dashboard, pay salaries at month end,
  log expenses (rent, utilities, delivery, …), and ask the assistant.

## Capabilities and Constraints

- Flutter Web, MVVM (provider). Every screen must work at phone, tablet and desktop widths, with
  text in all three languages (Tajik Cyrillic must render: ҳ ҷ қ ғ ӣ ӯ).
- Money arrives as decimal strings in TJS. Dates follow the business calendar
  (Asia/Dushanbe).
- The AI answer can take several seconds (up to about 60). The UI must show that it is thinking
  and fall back to local answers when the AI is unavailable.
- It is meant to become a real product used by real store owners, not only a class demo.

## Brand Commitments

- Name: Apex Suite. Mark: a two-peak ridge (the Pamirs) on a tile.
- Three switchable looks exist (Midnight Aurora, Zinc, Emerald), described in
  `docs/DESIGN_SYSTEM.md`. Visual decisions live there, not here.

## Evidence on Hand

- Real data from the live backend: stores, sales, payroll, expenses and AI answers.
- Photos: four Unsplash photos in `assets/images/` (credits in `assets/images/CREDITS.md`).
  They show US and Euro banknotes, not somoni.
- Absent and must not be invented: customer testimonials, customer counts, pricing or plans,
  press, certifications, or performance claims.

## Product Principles

1. **The owner's own numbers come first.** Every screen and every AI answer is grounded in real
   data from the API.
2. **Speak the owner's language.** Tajik is a first-class language, never an afterthought.
3. **Money must be clear at a glance.** What came in, what went out, and who still has to be
   paid.
4. **One business, every device.** The same truths on the web and the phone.
