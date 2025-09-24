<div align="center">
  <h1>📡 Advanced Wireless Access Simulation — NOMA & RSMA</h1>
  <p><b>Course:</b> EE632: Advanced Topics in Communication Systems (IIT Guwahati, 2025)</p>
  <p>
    <img alt="MATLAB" src="https://img.shields.io/badge/MATLAB-R202x-ff7f0e">
    <img alt="Status" src="https://img.shields.io/badge/Project-Type%3A%20Academic-blue">
  </p>
</div>

<hr>

<h2>🚀 Overview</h2>
<p>
This project implements <b>Monte Carlo simulations in MATLAB</b> for two modern multiple-access techniques:
<b>NOMA</b> (near &amp; far users with interference) and <b>RSMA</b> (SISO downlink, 2 users). Tasks follow the
EE632 Assignment-2 brief: derive/verify <b>outage probabilities (OP)</b> and evaluate <b>ergodic rates</b> vs. transmit power. :contentReference[oaicite:0]{index=0}
</p>

<h2>🎯 What’s Included</h2>
<ul>
  <li><b>NOMA:</b> Analytical OP for near user (closed-form) and Monte Carlo OP for near/far users; comparison plots.</li>
  <li><b>RSMA:</b> Monte Carlo <i>ergodic rates</i> and <i>outage probabilities</i> for both users across transmit powers.</li>
</ul>

<h2>📂 Repo Structure (suggested)</h2>
<pre>
/src
  noma_near_op_analytic.m
  noma_op_simulation.m
  rsma_rates_outage_sim.m
/figs
  noma_outage_vs_power.fig
  rsma_rates_vs_power.fig
  rsma_outage_vs_power.fig
README.md
</pre>

<h2>▶️ How to Run (MATLAB)</h2>
<ol>
  <li>Clone the repo and open <code>/src</code> in MATLAB.</li>
  <li>Run <code>noma_near_op_analytic.m</code> to generate the near-user closed-form OP function/curve.</li>
  <li>Run <code>noma_op_simulation.m</code> to simulate OP for near &amp; far users and save plots in <code>/figs</code>.</li>
  <li>Run <code>rsma_rates_outage_sim.m</code> to compute RSMA ergodic rates &amp; outages; plots saved in <code>/figs</code>.</li>
</ol>

<h2>📊 Expected Outputs</h2>
<ul>
  <li><b>NOMA OP vs Power:</b> Near (sim vs analytic) and Far (sim vs analytic from class) on one figure.</li>
  <li><b>RSMA:</b> (i) Ergodic rates of D1 &amp; D2; (ii) Outage probabilities of D1 &amp; D2.</li>
</ul>

<h2>🖼️ Plot Placeholders</h2>
<p>After running, add your saved figures (export as PNG) and reference them here:</p>
<ul>
  <li><code>![NOMA OP vs Power](figs/noma_outage_vs_power.png)</code></li>
  <li><code>![RSMA Rates vs Power](figs/rsma_rates_vs_power.png)</code></li>
  <li><code>![RSMA Outage vs Power](figs/rsma_outage_vs_power.png)</code></li>
</ul>

<h2>🧩 Notes</h2>
<ul>
  <li>Follow assignment parameters for channels, thresholds, and powers exactly (see PDF brief). :contentReference[oaicite:1]{index=1}</li>
  <li>Save MATLAB figures as <code>.fig</code> (and optional <code>.png</code>) for quick review.</li>
</ul>

<h2>📜 Reference</h2>
<p>EE632 Assignment-2 Instructions, 2 Apr 2025. :contentReference[oaicite:2]{index=2}</p>
