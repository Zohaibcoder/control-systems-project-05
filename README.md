# Root Locus Based Aircraft Pitch Controller Design Using MATLAB

**Classical Control Systems | Root Locus | Gain Margin Analysis | MATLAB | Aerospace Engineering**

This repository contains my fifth independent control systems project — Root Locus analysis and controller design for the aircraft longitudinal pitch dynamics system from Project 04. This project moves from trial-and-error PID tuning to analytical controller design using the Root Locus method.

---

## Engineering Question

> "Can an aircraft pitch controller be designed analytically using Root Locus instead of trial-and-error PID tuning, and how does its performance compare?"

**Short answer:** No — not with gain selection alone. The root locus shape is fundamentally unfavorable for this plant. This project proves why, analytically, and establishes what must be done next.

---

## Overview

Project 04 discovered experimentally that the aircraft pitch system goes unstable between Kp = 0.4 and Kp = 0.5. It provided no analytical explanation for why this happened at that specific gain, or whether any gain could meet the performance specifications.

Project 05 answers both questions using Root Locus:
- The exact gain margin is K = 0.46 — computed analytically via Routh-Hurwitz and confirmed by MATLAB margin()
- No gain value can meet OS < 10% and ts < 10s — the root locus never passes through the required pole region

---

## Plant

Same aircraft pitch transfer function from Project 04, with positive-gain sign convention to match the Simulink closed-loop implementation:

```
G(s) = (−1.282s + 1.282) / (s³ + 1.935s² + 0.987s + 0.179)
```

**Why K was flipped to +1.282:** Standard root locus traces poles as K goes from 0 to +∞. Using K = −1.282 traces the inverse root locus — showing poles moving in the wrong direction. Flipping to K = +1.282 matches the closed-loop implementation where a positive pitch command produces positive pitch angle.

---

## Root Locus Properties

| Property | Formula | Result |
|---|---|---|
| Number of poles (n) | — | 3 |
| Number of zeros (m) | — | 1 |
| Number of asymptotes | n − m | 2 |
| Asymptote angles | (2k+1)×180°/2 | **90° and −90°** |
| Asymptote centroid | (Σpoles − Σzeros)/(n−m) | **−1.4675** |
| Break-in point | dK/ds = 0 | **s = +1.7930** (RHP) |

The ±90° asymptote angles mean the two Phugoid branches travel straight up and down — they cross the imaginary axis vertically at a finite gain, causing instability.

---

## Gain Margin — Analytical Derivation

Setting s = jω in the characteristic equation and separating real/imaginary parts:

```
Real:      −1.935ω² + 0.179 + 1.282K = 0
Imaginary: −ω³ + (0.987 − 1.282K)ω = 0
```

Solving simultaneously (non-trivial solution):

| Solution | K | ω | Meaning |
|---|---|---|---|
| Trivial | −0.1396 | 0 | Real axis — not gain margin |
| **Critical** | **0.4600** | **±0.6303 rad/s** | **Imaginary axis crossing — GAIN MARGIN** |

**MATLAB margin() Confirmation:**

| Quantity | Value |
|---|---|
| Gain Margin | **0.4600** |
| Phase Margin | −47.16° (negative — conditionally stable) |
| Phase Crossover Frequency | 0.6303 rad/s |
| Critical Gain Kcrit | **0.4600** |

**This exactly matches the experimental result from Project 04** — instability between Kp = 0.4 and Kp = 0.5. Root locus gives the precise analytical answer: K = 0.46.

---

## Desired Performance Region Analysis

Performance specifications converted to pole requirements:

| Spec | Requirement | Pole Constraint |
|---|---|---|
| Overshoot < 10% | ζ ≥ 0.59 | Poles within damping ratio lines |
| Settling time < 10s | σ ≥ 0.4 | Poles left of σ = −0.4 |

**Critical result: The root locus does NOT pass through the desired region.**

The Phugoid branches start near the imaginary axis and curve INTO the RHP. They never satisfy both constraints simultaneously. This is the analytical proof that simple gain selection cannot meet the specifications.

---

## Analytical Gain Testing

| K | Rise Time | Settling Time | Overshoot | SS Pitch | Phugoid Poles |
|---|---|---|---|---|---|
| 0.10 | 3.42 s | 13.23 s | 18.15% | 2.465° (SSE=50.7%) | −0.2181 ± 0.3967j |
| 0.20 | — | 28.62 s | 42.72% | 4.202° | −0.1413 ± 0.4935j |
| 0.35 | — | 72.63 s | 82.01% | 6.505° | −0.0533 ± 0.5835j |
| 0.40 | — | 141.93 s | 95.64% | 7.251° | −0.0282 ± 0.6062j |

**Every gain increase worsens performance.** Phugoid pole real parts move from −0.2181 toward −0.0282 — closer to the imaginary axis, less damped, more oscillatory. The best available gain is K = 0.1.

---

## Controller Comparison

| Controller | Rise Time | Settling Time | Overshoot | Undershoot | SS Error |
|---|---|---|---|---|---|
| Open Loop | 7.56 s | 13.93 s | 0.23% | 3.16% | Very large |
| **Root Locus K=0.1** | **3.42 s** | **13.23 s** | **18.15%** | **5.49%** | **50.7%** |
| Root Locus K=0.4 | — | 141.93 s | 95.64% | — | 27% |
| PID — pidtune() | 1.99 s | 19.49 s | 3.39% | 18.12% | **0% ✅** |

**Why PID outperforms root locus gain selection:** The integral term in PID drives SSE to zero — a capability that no proportional gain can provide. Root locus gain selection can only place poles; it cannot add controller dynamics. PID adds the integrator 1/s which changes what is achievable.

---

## Key Engineering Conclusions

**1.** Gain margin K = 0.46 confirmed analytically — exactly matching the Project 04 experimental discovery.

**2.** The ±90° asymptotes mean Phugoid branches cross the imaginary axis vertically at K = 0.46. This is geometrically unavoidable given the plant's pole-zero configuration.

**3.** Root locus does not pass through the desired performance region. OS < 10% and ts < 10s cannot both be satisfied at any gain value.

**4.** Every gain increase worsens performance on this plant — the opposite of minimum-phase plants where increasing gain improves speed up to a stability limit.

**5.** Best available gain K = 0.1 still has 50.7% steady-state error. PID eliminates this via integral action; root locus gain alone cannot.

**6.** The root locus must be reshaped using a lead compensator before gain selection becomes meaningful. This is the subject of Project 06.

---

## Why Root Locus Still Matters

Even though pure gain selection failed here, root locus analysis provided three things that trial-and-error PID tuning could not:

- **Exact gain margin** (K = 0.46) — not an approximation
- **Physical explanation** of why instability occurs (Phugoid poles crossing imaginary axis at ±90°)
- **Proof** that the plant needs compensator design, not just better tuning

This is what distinguishes an engineer from a button-clicker — understanding why, not just what.

---



## Project Roadmap

```
✅ Project 01 — Mass-Spring-Damper Analysis
✅ Project 02 — DC Motor Modeling
✅ Project 03 — PID Speed Control
✅ Project 04 — Aircraft Pitch Control
✅ Project 05 — Root Locus Design ← YOU ARE HERE

→ Project 06 — Lead Compensator Design
→ Project 07 — Bode & Frequency Response
→ Project 08 — State-Space Modeling
→ Project 09 — Pole Placement
→ Project 10 — LQR Optimal Control
→ Project 11 — Kalman Filter
→ Project 12 — UAV Attitude Control
→ Project 13 — Rocket Attitude Control
→ Project 14 — Satellite Attitude Control
→ Project 15 — Complete Flight Control System
```

---

## Software Used

- MATLAB R2024b
- Control System Toolbox

---

## Author

**Zohaib Imtiaz**
Aerospace Engineering Student | Teknofest VLR Team — Flight Control

---

## License

This project is released under the MIT License.

## Project Cover

![Project Cover](Figures/ProjectCover.png)
