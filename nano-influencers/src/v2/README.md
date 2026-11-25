# Nano Influencers V2 frontend

This directory is the controlled rebuild of the Nano Influencers advertiser frontend from the Figma `Nano-Influencers-V2` page.

## Guardrails

- Do not modify `click-workers/` as part of this rebuild.
- Preserve the current FastAPI contracts and advertiser auth/session behavior unless a documented contract gap requires a backend change.
- Keep the browser refresh token in the existing HttpOnly-cookie flow; do not move refresh credentials into localStorage/sessionStorage.
- Do not call `POST /campaigns` until the advertiser confirms the final campaign preview because campaign creation locks escrow and creates worker tasks.
- Treat Figma as the visual source of truth and GitHub as the code source of truth.
- Build platform-specific campaign screens from shared configuration rather than duplicating one form per social platform.

## Planned layers

- `app/` — V2 route and provider composition.
- `config/` — service/platform definitions used by the campaign builder.
- `features/` — domain-specific UI and state.
- `styles/` — Figma-derived design tokens and global V2 styles.
- `components/` — reusable UI, layout, and marketing primitives.

## Rollout

The existing `advertiser-app.jsx` remains the production entry point while V2 foundations are built and verified. V2 replaces routes incrementally only after the corresponding Figma screens and behavior are ready.
