# Neon Tether: Design Document

## Game Concept

A top-down, arena-survival action game where the player controls a central
anchor point in a 3D space. One or more orbiting saw blades rotate continuously
around the anchor to destroy geometric enemies while the player navigates the
arena.

---

## Core Mechanics

- **Movement:** WASD or Joystick.
- **Combat:** Passive auto-spin. The weapon deals damage only when the blade's
  "Strike Zone" (leading edge) contacts an enemy.
- **Progression:** Enemies drop XP orbs. Filling the XP bar triggers an upgrade
  menu.
- **Weapon Scaling:** Upgrade paths allow for additional blades, increased
  range, and specialized stats.
- **Game Over:** Health reaches zero upon enemy collision with the anchor.

---

## Gameplay Elements

### Player & Weapon

- **Anchor:** The player’s core. Getting hit causes a "red pulse" visual
  feedback.
- **Tethered Saws:** Passive, continuous auto-spin. Damage is dealt only when
  the blade contacts an enemy. Continuous damage is dealt as DoT while the saw
  is still in contact with an enemy.
- **Saw Count:** Increasing this adds more tethered arms to the anchor.
- **Dynamic Camera:** The camera automatically adjusts zoom to keep a constant
  player-to-screen ratio as the attack radius grows.
- **Visibility Indicators:**
    - **Attack Radius:** A persistent UI ring showing the orbit range of the
      blades.
    - **Collection Radius:** A separate visual ring showing the pickup range for
      XP orbs.

---

### Enemies

| Role        | Shape    | Color  | Health | Movement   | Telegraph                      |
| :---------- | :------- | :----- | :----- | :--------- | :----------------------------- |
| **Blocker** | Cube     | Purple | High   | Slow       | Impact circle on floor         |
| **Seeker**  | Sphere   | Red    | Low    | Orbit/Dash | Brief pause before lunging     |
| **Charger** | Prism    | Orange | Medium | Linear     | Projected indicator            |
| **Burster** | Cylinder | Yellow | Medium | Ranged     | Squash down (prep) / Up (fire) |

#### Mechanics

- **Blocker:**
    - **Behavior:** Primary fodder. Moves slowly toward the player.
    - **Attack:** AoE slam. After a wind-up (telegraphed by an impact circle),
      it slams the ground, applying a movement speed debuff to the player.
- **Seeker:**
    - **Behavior:** Circles the arena perimeter. Periodically locks onto the
      player's current position and dashes in a straight line.
    - **Attack:** High impact damage. The enemy destroys itself upon collision
      with the player or an arena wall. Can be dodged.
- **Charger:**
    - **Behavior:** Approaches the player. When in range, it pauses to prepare a
      high-speed lunge.
    - **Attack:** Dashes in a straight line toward the player's location at the
      start of the preparation phase. Telegraphs via a projected line on the
      ground.
- **Burster:**
    - **Behavior:** Maintains a fixed distance from the player to act as ranged
      artillery.
    - **Attack:** Auto-attack projectiles that do not miss. Telegraphs by
      "squishing" down (wind-up) and popping up (firing).

---

### Arena & Wave Dynamics

#### Arena Progression

- **Expansion:** The arena begins as a tight circle. Every 5 waves, the radius
  expands, increasing the total playable space.
- **Arena Shifting (Potential):** The play area may dynamically shift its center
  position during gameplay.
    - _Strategic Risk:_ Players must choose between chasing distant XP or
      staying in a safer, central position.
- **Visuals:** The arena is defined by a glowing neon ring boundary.

#### Wave Structure

- **Wave Unlocking:** Sequential intro: **Blocker → Burster → Charger →
  Seeker**.
- **Scaling Weights:** Spawn weights shift from Blocker-heavy to Seeker-heavy as
  waves progress.
- **Specialized Waves:** Every 5 waves, the spawning pool is restricted to only
  two enemy types to test specific build optimizations.
    - **Elite/Boss (Potential):** Every 5-wave checkpoint may spawn a "Large"
      (Boss) version of the active enemy types.

---

### Upgrades

| Stat                 | Category | Type       | Description               | Strategic Purpose           |
| :------------------- | :------- | :--------- | :------------------------ | :-------------------------- |
| **Damage**           | Offense  | Flat       | Base damage increase      | Raw damage per strike.      |
| **Attack Radius**    | Offense  | Flat       | Expand reach              | Increase safe zone/hit box. |
| **Spin Speed**       | Offense  | Percentage | Angular velocity +        | Increase strike frequency.  |
| **Crit Chance**      | Offense  | Percentage | Proc chance for 2x damage | Damage multipliers.         |
| **Blade Size**       | Offense  | Flat       | Increase hit box area     | Easier enemy contact.       |
| **Blade Count**      | Offense  | Flat       | +1 Saw Arm                | Additional strike zones.    |
| **Max Health**       | Defense  | Flat       | Increase total HP         | Buffer against failure.     |
| **Health Regen**     | Defense  | Flat       | Periodic HP restore       | Passive sustain.            |
| **Evasion**          | Defense  | Percentage | Chance to avoid damage    | Mitigation.                 |
| **Lifesteal**        | Defense  | Percentage | HP recovery on hit        | Active sustain.             |
| **Shield Count**     | Defense  | Flat       | +1 Layer of protection    | Emergency buffer.           |
| **Knockback Force**  | Defense  | Percentage | Increase push distance    | Keep enemies out of orbit.  |
| **Move Speed**       | Utility  | Percentage | Increase player speed     | Repositioning.              |
| **Collection Range** | Utility  | Flat       | Increase pickup radius    | Gather XP from distance.    |

#### Menu

- **Menu Access:** You can access the upgrade menu at any time by pressing the
  dedicated menu button; there are no forced interruptions to gameplay.
- **Selection:** When the menu is open, you are presented with four distinct
  options:
    1. One **Offense** card.
    2. One **Defense** card.
    3. One **Utility** card.
    4. One **Random** card (The "Gamble" option).

#### Gambling Mechanic

Choosing the **Random** card initiates a high-stakes roll:

- **The Risk:** 50% chance the card results in a "Dud," yielding no upgrade.
- **The Reward:** 50% chance for a "Win," doubling the stat effect (equivalent
  to receiving two standard cards simultaneously).

---

## Technical Specifications

### Leveling & Progression Logic

The leveling curve is designed to encourage fast early-game progression,
transitioning into strategic long-term scaling.

**Max XP Calculation:** We use an exponential growth formula to determine the
experience required for the next level:

$$TargetXP = 100.0 \times 1.2^{(Level - 1)}$$

- **XP Orbs:** Orbs are persistent and do not expire, allowing players to
  collect missed XP if the play area shifts.

| Level | XP Required |     | Level | XP Required |
| :---- | :---------- | :-- | :---- | :---------- |
| 1     | 100.0       |     | 11    | 619.2       |
| 2     | 120.0       |     | 12    | 743.0       |
| 3     | 144.0       |     | 13    | 891.6       |
| 4     | 172.8       |     | 14    | 1069.9      |
| 5     | 207.4       |     | 15    | 1283.9      |
| 6     | 248.8       |     | 16    | 1540.7      |
| 7     | 298.6       |     | 17    | 1848.8      |
| 8     | 358.3       |     | 18    | 2218.6      |
| 9     | 430.0       |     | 19    | 2662.3      |
| 10    | 516.0       |     | 20    | 3194.8      |

---

### Enemy Scaling System

Enemies scale based on a **Global Difficulty Multiplier** that increases every
10 waves. This ensures that even as the player gains strength, the enemies
maintain their threat level.

- **Difficulty Formula:** Start at 1.0 and add 3% (0.03) for every full wave
  completed.

- **Scaling Application:**
    - **Enemy Health:** Final Health = Base Health × Difficulty Multiplier
    - **Enemy Damage:** Final Damage = Base Damage × Difficulty Multiplier
    - **Enemy Speed:** Final Speed = Base Speed × (1 + (Difficulty
      Multiplier - 1) / 2)

| Wave | Difficulty Multiplier (HP/Dmg) | Speed Modifier |
| :--- | :----------------------------- | :------------- |
| 1    | 1.00x                          | 1.00x          |
| 5    | 1.12x                          | 1.06x          |
| 10   | 1.27x                          | 1.14x          |
| 15   | 1.42x                          | 1.21x          |
| 20   | 1.57x                          | 1.29x          |
| 25   | 1.72x                          | 1.36x          |
| 30   | 1.87x                          | 1.44x          |
| 35   | 2.02x                          | 1.51x          |
| 40   | 2.17x                          | 1.59x          |
| 45   | 2.32x                          | 1.66x          |
| 50   | 2.47x                          | 1.74x          |

> **Note on Speed:** Enemy speed scales at half the rate of health and damage to
> ensure the game remains fair and dodgeable as the difficulty increases.

---

### Spawn Weight Management

A weighted random selection system. As the wave number increases, the `weight`
for Blocker enemies is programmatically decreased, while the `weight` for
Seeker, Charger, and Burster enemies increases.

- **Initial Weighting (Wave 1):** 100% Blocker
- **Late Game Weighting (Wave 50+):** 20% Blocker, 30% Burster, 25% Charger, 25%
  Seeker.

This system ensures a gradual shift in the arena's threat profile, maintaining a
fresh challenge as the wave count climbs.
