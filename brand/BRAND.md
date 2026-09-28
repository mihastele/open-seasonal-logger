# Seasonal — Brand guidelines

Seasonal is a quiet tool for exploring one thing at a time. The brand should
feel like **paper, clay, and a single brush stroke** — warm, handmade, and
calm. Nothing about it should feel like a dashboard, a score, or a deadline.

## The mark

A **paintbrush drawing a stroke.** The brush is the act of exploring; the
fresh stroke of paint it leaves behind is the season you are making. The
brush is tilted, mid-motion, and the paint is still warm — this is something
being worked on, not something finished and scored.

- Full colour on light backgrounds, one colour on dark or tinted fills.
- Clear space around the mark: at least 25% of the mark's height on all sides.
- Minimum size: 20 px for the app UI, 32 px anywhere it carries meaning.
- Do not rotate, stretch, add drop shadows, or place it on a busy photo.

## Palette

| Name        | Hex       | Use                                             |
| ----------- | --------- | ----------------------------------------------- |
| **Paper**   | `#FBF7F2` | App and site background. The default canvas.     |
| **Linen**   | `#F3E9DE` | Soft panels, gentle prompts, hairlines.          |
| **White**   | `#FFFFFF` | Cards.                                           |
| **Ember**   | `#B4633A` | Primary. Buttons, progress, the brush tip.       |
| **Amber**   | `#D99A4E` | Accent. The lit end of the leaf gradient.        |
| **Bark**    | `#5B4A3E` | Ferrule / dark warm neutral.                     |
| **Ink**     | `#3E332B` | Primary text on paper.                           |
| **Clay**    | `#6B5D50` | Body text.                                       |
| **Stone**   | `#8A7A6B` | Secondary text, labels, captions.                |
| **Moss**    | `#6E7B56` | Calm secondary accent (e.g. a returning season). |

The leaf gradient runs **Ember → Amber** (`#A9532F → #C97B44 → #E0A659`).

### Rules

- Warm neutrals carry the design; colours are accents, never a rainbow.
- **No red error/failure colour.** A season ending is never an error.
- **No green "success" colour for completion** — a season is not a task.
- **No red for destructive actions either.** Delete uses **Bark** with a
  confirm dialog, and edit uses **Amber**. Red is reserved for nothing; the
  palette stays free of it so the app never feels like a failure state.
- **Third-party brand colours do not enter the app.** The optional "Buy me a
  coffee" link uses Stone/Clay like any other quiet text link, never the
  Buy-Me-a-Coffee yellow.
- Contrast: Ink or Clay on Paper/White for body text; Stone only for
  non-essential labels.

## Type

- A humanist sans for UI and body (system default is fine: Inter, Roboto,
  Segoe UI, Helvetica).
- The wordmark is set in **uppercase, generously letter-spaced** (`SEASONAL`),
  in Stone or Ink.
- Headings use tight tracking and a heavy weight; body text is relaxed with
  generous line height (~1.5).

## Voice

- Warm, plain, and unhurried. Second person.
- Never guilt, never urgency, never "you fell behind".
- A season is successful if you genuinely explored something — say that, and
  mean it.
- Prefer questions over instructions: *"What would you like to explore next?"*

### Say

> Your season is ending soon. What would you like to explore next?
> Whatever you explored is enough.

### Don't say

> 5-day streak! Don't break it!
> You only completed 38% of your goal.

## Assets

```
brand/
  BRAND.md            this file
  logo/mark.svg       the brush-tip leaf mark
  logo/lockup.svg     mark + SEASONAL wordmark (horizontal)
  icons/              rendered app icons
```
