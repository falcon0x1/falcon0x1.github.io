---
title: "Just Delete the Test Data (The Most Dangerous Easy Task)"
date: 2026-10-26 10:00:00 +0200
categories: [Cloud Security, Storage]
tags: [firebase, gcs, cloud-storage, data-cleanup, bucket-security, pentest-ops]
toc: true
---

## 𓂀 The scariest moment isn't the exploit

On a lot of engagements the dangerous part isn't popping the box. It's the cleanup afterwards — the "quick" housekeeping task that everyone thinks is trivial.

Here's one that nearly deleted a pile of real customer data, and the reasoning trap behind it. It's worth walking through, because every wrong turn looked completely sensible at the time.

A team was getting ready to take a system live. Their file storage — a Firebase/GCS-style bucket — had filled up over months of development with two things mixed together: real customer documents (ID scans, company papers, payment receipts) and leftover test junk. Before go-live, they wanted the junk gone.

Simple ask. The *method* is where it got dangerous.

## 𓅃 The tempting shortcut

> "We have a clean dev environment. It has 15 folders. So let's delete everything in production that isn't one of those 15."

Dev is clean, prod is messy, so use dev as the ruler. Sounds reasonable on paper.

Running that rule would have deleted about **2,300 real files** — including identity documents and payment receipts.

Here's why — and why every "obvious" shortcut after it failed too.

## 𓂀 Wrong ruler #1: "it's not in dev, so it's junk"

Cloud storage folders are not real folders. There is no such thing as an empty folder in a bucket — a "folder" only exists once a file is written into it. It's just a prefix on an object's name.

So the dev environment had 15 folders for one reason: those were the only 15 actions anyone had ever performed there. Nobody uploaded a tax certificate in dev, so the `taxCertificates` folder simply didn't exist in dev. That doesn't make tax certificates junk. It means dev never did that action.

**"Missing from dev" meant "never exercised in dev," not "invalid."** Production had done everything, so production had every folder. The difference between them wasn't junk — it was real activity.

## 𓅃 Wrong ruler #2: "then use the code's folder list"

Fair enough — skip dev, go to the source. The backend code has an enum of the folders it writes to. Use that as the allow-list, delete the rest.

That list had 12 names. Production had a folder with **232 real company documents** — logos, VAT papers, registration docs — that wasn't on it. Confirmed live: the current app was actively writing to that folder. The path just happened to be built in a different part of the code, not through that enum.

So the code's own folder list was **incomplete**. Deleting "the rest" would have wiped 232 live documents on day one.

## 𓂀 Wrong ruler #3: "at least the loose files at the root are junk"

There were ~45 files dumped at the top level of the bucket with names like `IMG_6164.jpeg` and `screenshot.png` — no proper folder. Surely *those* are junk.

I opened one before putting it on any delete list. It was a real 29 KB profile photo. So were the rest — real profile pictures, bank documents, driver images. An old version of the upload code had **swapped the path parts**, storing each file as `<filename>/<category>` instead of `<category>/<filename>`. The files were real. Only the path was buggy.

Three reasonable heuristics. All three would have deleted real customer data.

## 𓅃 The only ruler that works: the database

A file in a bucket is junk if, and only if, **no live record points to it.**

The database is the ground truth. Every real file the app uses has its path stored somewhere — a logo path on a company record, a receipt URL on a transaction, an ID scan on a user. Export every path the database references, and you have the real keep-list. Anything in the bucket that isn't in that set is a genuine orphan, safe to delete — no matter which folder it's in, no matter the naming drift, no matter the path bugs.

It's more work than a folder diff. It's also the only version that doesn't destroy data.

## 𓂀 And one line about backups

"We have a backup, so we can just delete and restore if we're wrong" is the wrong instinct. A backup is a **safety net, not a licence**. Restoring thousands of real customer KYC files after a bad bulk delete is slow, and you're betting the restore is perfect on the exact data you can least afford to lose. Delete by the right rule and you never cash that bet.

## 𓅃 The takeaway

- Cloud storage folders are virtual — "empty" and "doesn't exist" are the same thing, and "missing" never means "junk."
- Don't build a delete-list from **structure** (dev, code, folder names). Build it from **references** (the database).
- Open a file before you delete it. The confident-looking junk is sometimes the realest data you have.
- Backups justify recovery, not recklessness.

The exploit wasn't the risk that day. The cleanup was.
