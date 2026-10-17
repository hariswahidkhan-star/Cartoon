# THE LANTERN SEA
### *an original animated feature — working title*

> *"Every light in the sky was once someone who loved the world too much to leave it."*

A 2D / anime-style animated feature. Epic. Emotional. A love story in the spirit of
*Tangled* and *The Lion King*, told in the visual language of *Your Name* and *Spirited Away*.

---

## What this repository is

This is the **production bible and pipeline** for the film. Making a world-class
animated feature is a multi-stage craft — this repo organizes every stage so the film
can be built the way real studios build them: story first, spectacle second.

```
docs/        → the creative foundation (START HERE)
  STORY_BIBLE.md        the concept, theme, and full story
  WORLD.md              the world, its rules, its rhythm
  CHARACTERS.md         who they are and why we love them
  VISUAL_STYLE.md       the look, palette, and art direction
  PRODUCTION_PIPELINE.md every tool and step to actually make it

script/      → the screenplay (feature format)
storyboard/  → shot-by-shot drawings (the e-conte)
art/         → concept art, character model sheets, backgrounds
shots/       → per-shot generation prompts & specs
renders/     → generated frames and clips
audio/       → voice, music, sound design
```

## The order of work (do not skip)

1. **Concept & theme** — the single idea that moves people → `docs/STORY_BIBLE.md`
2. **World & characters** → `docs/WORLD.md`, `docs/CHARACTERS.md`
3. **Script** — every scene on the page → `script/`
4. **Visual style lock** → `docs/VISUAL_STYLE.md`
5. **Storyboard** — every shot drawn → `storyboard/`
6. **Proof-of-concept shots** — prove the look → `shots/`, `renders/`
7. **Production & post** → full pipeline in `docs/PRODUCTION_PIPELINE.md`

## The honest scope

A 2-hour feature at world-class quality is a **studio-scale effort** (100+ artists,
2–4 years) or a **long, staged solo-with-AI build**. This repo is how one person, or a
small team, starts that journey professionally instead of generating disconnected clips.
We win on **story and art direction first** — that is what makes people cry, not frame count.

See `docs/PRODUCTION_PIPELINE.md` for the full toolchain (traditional + AI-assisted).
