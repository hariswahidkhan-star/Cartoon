# PRODUCTION PIPELINE & TOOLS — *The Lantern Sea*

> You asked which tools are required to make a world-class movie. Here is the complete,
> honest answer — both the traditional studio pipeline and the AI-assisted pipeline that a
> small team (or one determined person) can actually run today.

---

## TIER 1 — The professional studio toolchain

This is what Ufotable, CoMix Wave, and Ghibli actually use. If you ever scale to a team,
this is the target.

| Stage | Tool(s) | Notes |
|---|---|---|
| Screenwriting | **Final Draft**, WriterDuet | Industry-standard script formatting |
| Storyboard (e-conte) | **Toon Boom Storyboard Pro**, Procreate | Every shot drawn + timed |
| 2D animation | **Toon Boom Harmony** (industry std), **CLIP STUDIO PAINT EX**, OpenToonz (free, Ghibli's own tool!) | Character animation |
| Backgrounds | **Photoshop**, CLIP STUDIO, Procreate | Hand-painted, the Shinkai look |
| 3D (for complex camera/props) | **Blender** (free, pro-grade), Maya | Many anime use 3D for vehicles/crowds |
| Compositing / FX | **Adobe After Effects**, **Nuke**, Fusion | Bloom, light, the "magic" |
| Editing | **DaVinci Resolve** (free + pro), Premiere Pro | Cut the film |
| Color grading | **DaVinci Resolve** | The final premium polish |
| Sound design | **Pro Tools**, Reaper | |
| Music score | Logic Pro, Cubase + real orchestra | A great score is half the emotion |
| Voice recording | Pro Tools + booth | |

**Free path that's still world-class:** OpenToonz + Krita/CLIP STUDIO + Blender + DaVinci
Resolve. Ghibli literally helped build OpenToonz. Cost of software: ~$0–$300.

---

## TIER 2 — The AI-assisted pipeline (what we can run NOW)

This is how one person makes a *premium short* today, and how we prototype the feature.
Many of these I can drive directly from this session via the **Replicate** tools.

| Stage | AI models (available via Replicate) | Purpose |
|---|---|---|
| Concept art & key frames | **FLUX.1 [pro/dev]**, SDXL, Google **Imagen** | Paint the signature images |
| Character design sheets | FLUX + **LoRA fine-tuning** (train on your locked design) | Keep Ren & Suzu *consistent* — the #1 hard problem |
| Backgrounds | FLUX, SDXL with anime/painterly LoRAs | The Shinkai-style vistas |
| Image → video (animation) | **Kling**, **MiniMax/Hailuo**, **Luma Ray**, **WAN 2.x**, Hunyuan Video | Turn key frames into moving shots |
| Lip-sync / dialogue | lip-sync models (e.g. sadtalker-type, latentsync) | Characters actually speak |
| Voice / narration | TTS / voice-clone models | Temp or final voices |
| Music / score | **MusicGen**, melody models | Temp score and themes |
| Upscaling / cleanup | **Real-ESRGAN**, Topaz-style video upscalers | Push to 4K, premium finish |
| Frame interpolation | RIFE / film-net models | Smooth motion, higher fps |

### The hard truth about AI for a *feature*
- **Consistency** is the wall. AI drifts: the same character looks different every shot.
  The fix is **LoRA training** on a locked design + reference-image conditioning. Budget real
  time here — it's the difference between "amateur" and "premium."
- **Shot length**: current video models do ~5–10 clean seconds. A feature = thousands of
  shots stitched in an editor. This is *exactly* how real films work (films are made of short
  shots) — but it's a lot of generation and curation.
- **Cost**: generating a feature's worth of video on cloud GPUs is real money (hundreds to
  thousands of dollars depending on model and reruns). A *short* is very affordable.

---

## THE REALISTIC ROADMAP

### Phase 0 — Foundation *(we are here — costs nothing)*
Story bible ✓ · characters ✓ · world ✓ · visual style ✓ · opening script (in progress)

### Phase 1 — Lock the look *(cheap, high-impact)*
- Generate 3–5 **key-frame paintings** of the signature images → set the quality bar.
- Generate **character design sheets** for Ren & Suzu → train a LoRA for consistency.
- **Deliverable:** a "look book" that proves the film is premium. *This is the pitch.*

### Phase 2 — Proof-of-concept scene *(the magic moment)*
- Fully produce **one 60–90 second scene** end to end: key frames → video → voice → music →
  edit → grade. Recommended scene: **the lantern dance** (Act II) — the emotional + visual
  peak, our *Tangled* moment.
- **Deliverable:** one finished minute that looks and feels like the real film.

### Phase 3 — Decide the real build
With Phase 2 in hand, you choose honestly:
- **(a) Premium short (3–8 min):** fully achievable solo-with-AI. A festival-grade film.
- **(b) The feature:** requires a team + funding + 1–3 years. The look book + POC is how you
  recruit artists or raise money. This is the real path to the 2-hour film.

---

## What I can do from this session right now

- ✅ Write every document, script, shot list, and prompt (done / ongoing).
- ✅ Drive **Replicate** to generate concept art, character sheets, key frames, and video
  clips — **one at a time, with your budget approval**, since it spends on your account.
- ✅ Assemble prompts and specs per shot in `shots/` so generation is systematic, not random.
- ⚠️ I can't run Toon Boom/After Effects/DaVinci (desktop apps) — those are your hands, and
  I'll give you exact step-by-steps when we reach them.

**Next concrete step:** generate the first key-frame painting (the signature image) so you
can *see* the premium look. Say the word and I'll set it up — I'll confirm the model and the
rough cost before spending anything.
