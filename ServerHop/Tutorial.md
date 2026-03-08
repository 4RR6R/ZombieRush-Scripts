# Zombie Rush — Low Ping Strategy

Force a connection to fresh servers near your region to eliminate zombie reach and latency issues.

---

## Goal

Force the matchmaking system to place you in a server that:

- Is physically located near your region  
- Is brand new or empty  
- Has optimal response time  

This helps prevent:

- "Zombie Reach" (being hit from far away)  
- High ping spikes  
- Input delay  
- Connecting to old, laggy server instances  

---

## Step 1 — The Blocking Method

Roblox prevents you from joining a server if it contains a user you have blocked.  
Use this to filter out bad servers.

### Instructions

1. Join a public Zombie Rush server.
2. Open the player list (Tab).
3. Block one random player in the server.
4. Leave the game immediately.
5. Press **Play** to rejoin.

If you are placed in another populated or laggy server, repeat the process.

Eventually, the system will be forced to create a new, empty server instance for you.

---

## Step 2 — Reset Block List (Automated)

After your session, your block list will contain random players.  
You can clear them instantly using a browser script instead of unblocking them manually.

### Instructions

1. Go to the Roblox website in your web browser.
2. Open the Developer Console (F12 or Right Click > Inspect > Console).
3. Paste the source code below and hit Enter:

[Unblocker.js](https://raw.githubusercontent.com/4RR6R/ZR-Scripts/refs/heads/main/ServerHope/Unblocker.js)

The script will iterate through your settings and unblock the users automatically.

---

## Expected Results

By following this strategy, you should experience:

- A fresh server instance (often 0 players initially)
- Significantly lower ping
- Accurate hitboxes on zombies
- No phantom hits or lag spikes

---

## Notes

- This method relies on standard matchmaking behavior.
- The unblocker script runs locally in your browser to automate button clicks.
