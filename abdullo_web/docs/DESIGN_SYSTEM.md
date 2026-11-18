# Apex Suite web: design system

A calm, data-first business dashboard. Navy is the base and carries trust. Orange is the
single accent and marks actions and attention. Motion is quick and quiet, with one
exception: the AI assistant has a little more life.

## Tokens

| What | Where | Notes |
|---|---|---|
| Colors | `lib/core/theme/app_colors.dart` | `navy` base, `orange` accent, `green` / `red` money up / down, `blue` / `purple` for categories, `muted` secondary text, `border`, `surfaceSoft` |
| Theme | `lib/core/theme/app_theme.dart` | Material 3. Tight headings (`w700`, negative letter-spacing), 10px button radius, 18px dialogs, 12px menus, orange focus ring on inputs |
| Motion | `lib/core/motion/motion.dart` | `fast` 150ms (press, hover), `base` 240ms (page switch, popovers), `slow` 380ms (bubbles, cards), `reveal` 700ms (progress bars), `stagger` 45ms |
| Curves | `Motion.easeOut` = `Cubic(0.23, 1, 0.32, 1)` | Strong ease-out for anything entering. `Motion.easeInOut` for movement on screen. Never ease-in. |
| Breakpoints | `lib/core/responsive/breakpoints.dart` | `< 600` phone (bottom bar), `600–1023` tablet (compact rail), `>= 1024` desktop |

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
