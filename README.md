# QTRS Nexus ERP: setup and hosting (Supabase + Netlify)

## 1. Supabase (database + logins), about 10 minutes
1. supabase.com > New project. Pick the region closest to Qatar and a strong database password.
2. SQL Editor > New query > paste all of `schema.sql` > Run.
3. Authentication > Providers > Email: turn OFF "Confirm email" (new accounts still need admin approval inside the app).
4. Project Settings > API: copy the **Project URL** and the **anon public** key.
   Never use the service_role key.

## 2. Configure the site
Open `site/config.js` and paste the URL and anon key. Nothing else needs editing.

## 3. Host on Netlify (recommended)
1. app.netlify.com > sign up > Add new site > Deploy manually.
2. Drag the `site` folder (index.html, config.js, _headers) onto the page. You get a https://xxxx.netlify.app link.
3. Site configuration > Domain management: rename the site or add your own domain (HTTPS is automatic).
4. Supabase > Authentication > URL Configuration: set Site URL to your Netlify address.
To update later: edit the files and drag the folder again (Deploys > drag and drop).
Optional: put the folder in a PRIVATE GitHub repo and use Add new site > Import from Git for automatic deploys.

## 4. First login
Open your site > "Create an account". The FIRST account becomes administrator.
Sign in > Users & Logins to add staff (email, password, role, company, modules) or approve people who signed up (they show as "pending").
Settings > Load demo data (only while empty) if you want sample records. Otherwise start entering real data.

## 5. Before going live
- Supabase free projects pause after inactivity and have no daily backups: use the Pro plan for company data.
- Use Settings > Export backup (JSON) regularly.
- Share the site link only with staff; every user needs an approved account.
