---
name: deploy
description: Deploy the Next.js app to Vercel and/or the marketing site to Cloudflare Pages. Usage - /deploy app, /deploy site, or /deploy all.
disable-model-invocation: true
---

# Deploy

Deploy the Threshold Coaching platform to production.

## Arguments

- `app` — Deploy the Next.js app to Vercel production
- `site` — Deploy the marketing site to Cloudflare Pages
- `all` — Deploy both

If no argument is provided, ask which target to deploy.

## Commands

### App (Vercel)

```bash
vercel --prod
```

### Site (Cloudflare Pages)

```bash
make deploy
```

This runs `cd website && npx wrangler pages deploy . --project-name=threshold-coaching --branch=main --commit-dirty=true`.

## Post-deploy

After deploying, report:
- The deployment URL
- Whether the build succeeded
- Any warnings from the build output
