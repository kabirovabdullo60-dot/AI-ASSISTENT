# Apex Suite web: design system

The web has three looks, which the owner switches in **Settings → Theme** or from the palette
button in the top bar. The choice is saved in the browser. Every color role lives in
`lib/core/theme/app_palette.dart`, and widgets read the current palette through `AppColors`.

| Look | Mood | Background / card | Accent / AI accent |
|---|---|---|---|
| **Midnight Aurora** (default, dark) | Night navy lit by aurora glows | #0A0E1A / #121829 | violet #7C5CFF / cyan #22D3EE |
| **Zinc** (light) | shadcn-style zinc neutrals | #FAFAFA / #FFFFFF | indigo #4F46E5 / violet #A855F7 |
| **Emerald** (light) | Private-bank calm | #FAFAF7 / #FFFFFF | emerald #065F46 / champagne #C9A227 |

Roles include `strong` (chart marks: dark on light looks, light on dark) and `tooltip`
(dark label behind white text in every look).

## Premium motion (Magic UI ideas, rebuilt in Flutter)

| Effect | Widget | Where |
|---|---|---|
| Number ticker | `NumberTicker` | Money KPIs count up from 0 |
| Magic card spotlight | `Pressable` | An accent glow follows the cursor on cards; lift 2px; press 0.98 |
| Border beam | `BorderBeam` | Unpaid salaries KPI (2 laps), AI input bar (runs while the AI answers) |
| Shimmer button | `ShimmerSweep` | Record sale and Add expense: one sweep on show, again on hover |
| Aurora | `AuroraBackground` | AI start screen and login: three glows drift for 14s, then rest |
| Animated gradient text | `AnimatedGradientText` | The AI heading only |

Rule: nothing loops forever on an idle screen. Effects run a few laps and rest, and they wake up on
hover or while work is happening. Reduced motion removes all movement.

## Tokens

| What | Where | Notes |
|---|---|---|
| Colors | `lib/core/theme/app_colors.dart` | `background` #EDF2F6, `ink` #142235, `muted` #64748B (4.8:1), `teal` #087F80 accent (`tealSoft` #E1F0EF), `border` #DCE4EC, `gold` #E9A23B secondary accent (fills only), `amber` #B25E09 attention, `green` / `red` money. Old names `orange` / `navy` are aliases of the accent and the dark surface. |
| Type | `assets/fonts/Onest.ttf` (OFL) | Onest, a variable font with full Tajik Cyrillic (ҳ ҷ қ ғ ӣ ӯ), bundled so it works offline. Headings use w700 and −0.02em tracking. KPI numbers use tabular figures. Sentence case everywhere, with no all-caps labels and no eyebrows above headings. |
| Surfaces | `lib/core/theme/app_theme.dart` | Cards have a 1px stone border and no shadow (elevation is declared once), with a 14px radius. Pills are only for small badges. Selection, caret, scrollbar and focus ring are themed teal. |
| Brand | `lib/widgets/brand_mark.dart`, `pamir_ridge.dart` | A teal tile with a two-peak ridge drawn as vector lines. On the login page, layered ridgelines draw themselves once. |
| Motion | `lib/core/motion/motion.dart` | `fast` 150ms, `base` 240ms, `slow` 380ms, `reveal` 700ms, `stagger` 45ms. `Motion.easeOut` = `Cubic(0.23, 1, 0.32, 1)`. |
| Breakpoints | `lib/core/responsive/breakpoints.dart` | `< 600` phone (bottom bar), `600–1023` tablet (compact rail), `>= 1024` desktop. The login splits into two halves at `>= 900`. |

## Visual review

`test/capture/screens_test.dart` renders every page with the real Onest font to PNG
(desktop 1440 and phone 400):
`flutter test test/capture/screens_test.dart --dart-define=CAPTURE=true --dart-define=OUT=build/screens`

## Motion rules

1. Every animation has a reason: feedback, spatial continuity or a state change. Nothing loops on an idle screen.
2. UI feedback stays under 300ms. Data reveals can take up to 700ms.
3. Nothing appears from scale 0. Entrances start at 0.9–0.96 scale plus a fade and a few pixels of movement.
4. Hover lift only reacts to a real mouse, and press feedback is a 0.97 scale.
5. Reduced motion (`Motion.reduced`): movement is removed and fades stay. Typed answers appear at once.
6. Delays are part of the animation controller (an `Interval`), never timers, so nothing fires after a widget is gone.

## Motion widgets (`lib/widgets/motion/`)

| Widget | Use |
|---|---|
| `FadeSlideIn` | Entrance (fade, move, optional scale) with a `delay` for staggered groups |
| `Pressable` | Hover lift with shadow plus press scale for cards and chips |
| `PageSkeleton` | Shimmer page placeholder while the first load runs (`AsyncContent`) |
| `AiOrb` | The assistant's face. Gradient orb; it swirls and breathes only while `thinking` |
| `TypingIndicator` | Orb plus three dots in a wave plus "Thinking…" while the answer is coming |
| `TypewriterText` | A fresh answer types out (≤ 1.6s, any length), then becomes selectable text |

## Where motion is used

- **Page switch** (`HomeView`): the new page fades in and rises 8px, and the old page fades out faster.
- **Dashboard**: KPI cards cascade in and lift on hover. Target progress bars fill from 0.
- **Sidebar**: the selected item's orange pill and glow animate between items.
- **AI assistant**: the orb and the intro cascade in, then the suggestion cards. Questions slide in from the right and answers from the left, next to the orb. While waiting, the thinking indicator shows, and the send button turns into a spinner.
- **Loading**: shimmer skeleton instead of a bare spinner.

## Tests

`test/motion_test.dart` covers the skeleton, the thinking indicator, the typed answer, and the whole chat with reduced motion turned on.
