(function() {
  "use strict";

  var LENSES = ["labor", "revenue", "opportunity", "goodwill"];

  var STAGE_NAMES = {
    zero_to_need: "Zero -> Identified Need for Developer Role",
    need_to_req: "Identified Need -> Job Req",
    job_req_to_hiring: "Job Req -> Hiring Process",
    hiring_to_onboarding: "Hiring Process -> Onboarding",
    onboarding_to_functional: "Onboarding -> Functional",
    functional_to_operational: "Functional -> Operational",
    operational_to_independent: "Operational -> Independent",
    independent_to_leverage: "Independent -> Leverage",
    employment_microloop_friction: "Employment Microloop Friction",
    retention_to_exit: "Retention Risk -> Exit",
    exit_to_backfill: "Exit -> Backfill Complete"
  };

  var DEFAULTS = {
    team_size: 10,
    salary_min: 50000,
    salary_max: 100000,
    loaded_cost_multiplier: 1.3,
    workdays_per_year: 260,
    compounding_k: 0.01,
    weights: { labor: 25, revenue: 25, opportunity: 25, goodwill: 25 },
    global_rates: { revenue: 0, opportunity: 0, goodwill: 0 },
    interview: {
      candidates: 6,
      interviewers: 3,
      rounds: 4,
      hours_per_round: 1,
      prep_debrief_hours_per_candidate: 1.5
    },
    dora: {
      deployments_per_month: 20,
      lead_time_actual_days: 3,
      lead_time_target_days: 1,
      cfr_actual_pct: 15,
      cfr_target_pct: 10,
      mttr_actual_hours: 12,
      mttr_target_hours: 4
    }
  };

  function $(id) { return document.getElementById(id); }

  function money(n) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD",
      maximumFractionDigits: 0
    }).format(n || 0);
  }

  function fixed(n, digits) { return Number(n || 0).toFixed(digits); }
  function toNumber(value, fallback) {
    var n = Number(value);
    return Number.isFinite(n) ? n : fallback;
  }
  function clone(obj) { return JSON.parse(JSON.stringify(obj)); }

  function normalizeWeights(weights) {
    var total = 0;
    LENSES.forEach(function(lens) { total += Math.max(0, toNumber(weights[lens], 0)); });
    if (total <= 0) return null;
    var normalized = {};
    LENSES.forEach(function(lens) {
      normalized[lens] = Math.max(0, toNumber(weights[lens], 0)) / total;
    });
    return normalized;
  }

  function buildSalaryDistribution(teamSize, minSalary, maxSalary) {
    var salaries = [];
    if (teamSize <= 1) return [minSalary];
    var step = (maxSalary - minSalary) / (teamSize - 1);
    for (var i = 0; i < teamSize; i += 1) {
      salaries.push(minSalary + (step * i));
    }
    return salaries;
  }

  function base64Encode(str) {
    return btoa(unescape(encodeURIComponent(str))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
  }

  function base64Decode(str) {
    var value = str.replace(/-/g, "+").replace(/_/g, "/");
    while (value.length % 4) value += "=";
    return decodeURIComponent(escape(atob(value)));
  }

  function readStageRows() {
    var rows = document.querySelectorAll("[data-stage-id]");
    var stages = [];
    rows.forEach(function(row) {
      function readField(name) {
        var input = row.querySelector("[data-field=\"" + name + "\"]");
        return input ? input.value : "";
      }
      var id = row.getAttribute("data-stage-id");
      stages.push({
        id: id,
        name: STAGE_NAMES[id] || id,
        target_days: toNumber(readField("target"), 0),
        actual_days: toNumber(readField("actual"), 0),
        overrides: {
          labor: readField("labor_override") === "" ? null : toNumber(readField("labor_override"), 0),
          revenue: readField("revenue_override") === "" ? null : toNumber(readField("revenue_override"), 0),
          opportunity: readField("opportunity_override") === "" ? null : toNumber(readField("opportunity_override"), 0),
          goodwill: readField("goodwill_override") === "" ? null : toNumber(readField("goodwill_override"), 0)
        }
      });
    });
    return stages;
  }

  function collectInput() {
    return {
      team_size: toNumber($("team_size").value, DEFAULTS.team_size),
      salary_min: toNumber($("salary_min").value, DEFAULTS.salary_min),
      salary_max: toNumber($("salary_max").value, DEFAULTS.salary_max),
      loaded_cost_multiplier: toNumber($("loaded_cost_multiplier").value, DEFAULTS.loaded_cost_multiplier),
      workdays_per_year: toNumber($("workdays_per_year").value, DEFAULTS.workdays_per_year),
      compounding_k: toNumber($("compounding_k").value, DEFAULTS.compounding_k),
      weights: {
        labor: toNumber($("weight_labor").value, DEFAULTS.weights.labor),
        revenue: toNumber($("weight_revenue").value, DEFAULTS.weights.revenue),
        opportunity: toNumber($("weight_opportunity").value, DEFAULTS.weights.opportunity),
        goodwill: toNumber($("weight_goodwill").value, DEFAULTS.weights.goodwill)
      },
      global_rates: {
        revenue: toNumber($("global_revenue_rate").value, DEFAULTS.global_rates.revenue),
        opportunity: toNumber($("global_opportunity_rate").value, DEFAULTS.global_rates.opportunity),
        goodwill: toNumber($("global_goodwill_rate").value, DEFAULTS.global_rates.goodwill)
      },
      interview: {
        candidates: toNumber($("candidates").value, DEFAULTS.interview.candidates),
        interviewers: toNumber($("interviewers").value, DEFAULTS.interview.interviewers),
        rounds: toNumber($("rounds").value, DEFAULTS.interview.rounds),
        hours_per_round: toNumber($("hours_per_round").value, DEFAULTS.interview.hours_per_round),
        prep_debrief_hours_per_candidate: toNumber($("prep_debrief_hours_per_candidate").value, DEFAULTS.interview.prep_debrief_hours_per_candidate)
      },
      dora: {
        deployments_per_month: toNumber($("dora_deployments_per_month").value, DEFAULTS.dora.deployments_per_month),
        lead_time_actual_days: toNumber($("dora_lead_time_actual_days").value, DEFAULTS.dora.lead_time_actual_days),
        lead_time_target_days: toNumber($("dora_lead_time_target_days").value, DEFAULTS.dora.lead_time_target_days),
        cfr_actual_pct: toNumber($("dora_cfr_actual_pct").value, DEFAULTS.dora.cfr_actual_pct),
        cfr_target_pct: toNumber($("dora_cfr_target_pct").value, DEFAULTS.dora.cfr_target_pct),
        mttr_actual_hours: toNumber($("dora_mttr_actual_hours").value, DEFAULTS.dora.mttr_actual_hours),
        mttr_target_hours: toNumber($("dora_mttr_target_hours").value, DEFAULTS.dora.mttr_target_hours)
      },
      stages: readStageRows()
    };
  }

  function validateInput(input) {
    var errors = [];
    if (input.team_size < 1) errors.push("Team size must be at least 1.");
    if (input.salary_min < 0 || input.salary_max < 0) errors.push("Salary bounds must be non-negative.");
    if (input.salary_max < input.salary_min) errors.push("Salary max must be greater than or equal to salary min.");
    if (input.loaded_cost_multiplier <= 0) errors.push("Loaded cost multiplier must be greater than 0.");
    if (input.workdays_per_year <= 0) errors.push("Workdays per year must be greater than 0.");
    if (input.compounding_k < 0) errors.push("Compounding k cannot be negative.");

    var normalized = normalizeWeights(input.weights);
    if (!normalized) errors.push("At least one weight must be greater than 0.");

    input.stages.forEach(function(stage) {
      if (stage.target_days < 0 || stage.actual_days < 0) {
        errors.push("Stage days cannot be negative: " + stage.name + ".");
      }
    });

    if (input.dora.deployments_per_month < 0) errors.push("DORA deployments per month cannot be negative.");
    if (input.dora.lead_time_actual_days < 0 || input.dora.lead_time_target_days < 0) errors.push("Lead time values cannot be negative.");
    if (input.dora.cfr_actual_pct < 0 || input.dora.cfr_actual_pct > 100 || input.dora.cfr_target_pct < 0 || input.dora.cfr_target_pct > 100) {
      errors.push("Change failure rates must be between 0 and 100.");
    }
    if (input.dora.mttr_actual_hours < 0 || input.dora.mttr_target_hours < 0) errors.push("MTTR values cannot be negative.");

    return { valid: errors.length === 0, errors: errors, normalized_weights: normalized };
  }

  function lensDayRateForStage(stage, blendedDaily, globalRates) {
    return {
      labor: stage.overrides.labor !== null ? stage.overrides.labor : blendedDaily,
      revenue: stage.overrides.revenue !== null ? stage.overrides.revenue : globalRates.revenue,
      opportunity: stage.overrides.opportunity !== null ? stage.overrides.opportunity : globalRates.opportunity,
      goodwill: stage.overrides.goodwill !== null ? stage.overrides.goodwill : globalRates.goodwill
    };
  }

  function computeDoraOverlay(input, blendedDaily, cumulativeDelay) {
    var d = input.dora;
    var leadDelayDays = Math.max(0, d.lead_time_actual_days - d.lead_time_target_days) * d.deployments_per_month;
    var excessFailureRate = Math.max(0, d.cfr_actual_pct - d.cfr_target_pct) / 100;
    var excessFailures = excessFailureRate * d.deployments_per_month;
    var mttrDelayHours = Math.max(0, d.mttr_actual_hours - d.mttr_target_hours) * excessFailures;
    var mttrDelayDays = mttrDelayHours / 8;
    var totalDelayDays = leadDelayDays + mttrDelayDays;
    var multiplier = 1 + (input.compounding_k * (cumulativeDelay + totalDelayDays));

    var leadBaseByLens = {
      labor: leadDelayDays * blendedDaily,
      revenue: leadDelayDays * input.global_rates.revenue,
      opportunity: leadDelayDays * input.global_rates.opportunity,
      goodwill: leadDelayDays * input.global_rates.goodwill
    };
    var recoveryBaseByLens = {
      labor: mttrDelayDays * blendedDaily,
      revenue: mttrDelayDays * input.global_rates.revenue,
      opportunity: mttrDelayDays * input.global_rates.opportunity,
      goodwill: mttrDelayDays * input.global_rates.goodwill
    };
    var baseByLens = {
      labor: leadBaseByLens.labor + recoveryBaseByLens.labor,
      revenue: leadBaseByLens.revenue + recoveryBaseByLens.revenue,
      opportunity: leadBaseByLens.opportunity + recoveryBaseByLens.opportunity,
      goodwill: leadBaseByLens.goodwill + recoveryBaseByLens.goodwill
    };
    var compoundedByLens = {};
    LENSES.forEach(function(lens) {
      compoundedByLens[lens] = baseByLens[lens] * multiplier;
    });

    return {
      lead_delay_days: leadDelayDays,
      excess_failures: excessFailures,
      mttr_delay_days: mttrDelayDays,
      total_delay_days: totalDelayDays,
      multiplier: multiplier,
      lead_base_by_lens: leadBaseByLens,
      recovery_base_by_lens: recoveryBaseByLens,
      base_by_lens: baseByLens,
      compounded_by_lens: compoundedByLens
    };
  }

  function computeCore4(stageResults, doraOverlay, totalComposite) {
    function stageCost(id) {
      var match = stageResults.find(function(s) { return s.id === id; });
      return match ? match.weighted_composite : 0;
    }

    var cores = [
      {
        name: "Core 1: Planning and Staffing",
        value: stageCost("zero_to_need") + stageCost("need_to_req") + stageCost("job_req_to_hiring"),
        hint: "Clarify role signals and streamline requisition/interview flow."
      },
      {
        name: "Core 2: Enablement and Onboarding",
        value: stageCost("hiring_to_onboarding") + stageCost("onboarding_to_functional") + stageCost("functional_to_operational"),
        hint: "Remove access/setup blockers and shorten path to first meaningful contribution."
      },
      {
        name: "Core 3: Flow and Feedback",
        value: stageCost("operational_to_independent") + stageCost("independent_to_leverage") + stageCost("employment_microloop_friction") +
          ((doraOverlay.lead_base_by_lens.labor + doraOverlay.lead_base_by_lens.revenue + doraOverlay.lead_base_by_lens.opportunity + doraOverlay.lead_base_by_lens.goodwill) * doraOverlay.multiplier),
        hint: "Reduce wait states in review/CI/deploy loops and tighten feedback windows."
      },
      {
        name: "Core 4: Retention and Continuity",
        value: stageCost("retention_to_exit") + stageCost("exit_to_backfill") +
          ((doraOverlay.recovery_base_by_lens.labor + doraOverlay.recovery_base_by_lens.revenue + doraOverlay.recovery_base_by_lens.opportunity + doraOverlay.recovery_base_by_lens.goodwill) * doraOverlay.multiplier),
        hint: "Lower attrition friction and strengthen continuity before and after exits."
      }
    ];

    cores.forEach(function(core) {
      var pct = totalComposite > 0 ? (core.value / totalComposite) * 100 : 0;
      core.cost_share_pct = pct;
      core.health = Math.max(0, 100 - pct);
      core.label = pct >= 35 ? "High friction" : (pct >= 18 ? "Moderate friction" : "Lower friction");
    });

    return cores;
  }

  function computeResult(input, normalizedWeights, skipSensitivity) {
    var salaries = buildSalaryDistribution(input.team_size, input.salary_min, input.salary_max);
    var dailyCosts = salaries.map(function(salary) {
      return (salary * input.loaded_cost_multiplier) / input.workdays_per_year;
    });
    var blendedDaily = dailyCosts.reduce(function(sum, v) { return sum + v; }, 0) / dailyCosts.length;

    var panelHours = input.interview.candidates * (
      (input.interview.interviewers * input.interview.rounds * input.interview.hours_per_round) +
      input.interview.prep_debrief_hours_per_candidate
    );
    var panelLaborCost = (panelHours / 8) * blendedDaily;

    var cumulativeDelay = 0;
    var totals = {
      base_by_lens: { labor: 0, revenue: 0, opportunity: 0, goodwill: 0 },
      compounded_by_lens: { labor: 0, revenue: 0, opportunity: 0, goodwill: 0 },
      base_composite: 0,
      compounded_composite: 0,
      total_delay_days: 0
    };

    var stageResults = [];

    input.stages.forEach(function(stage) {
      var delayDays = Math.max(0, stage.actual_days - stage.target_days);
      cumulativeDelay += delayDays;
      totals.total_delay_days += delayDays;
      var multiplier = 1 + (input.compounding_k * cumulativeDelay);

      var rates = lensDayRateForStage(stage, blendedDaily, input.global_rates);
      var baseByLens = {};
      var compoundedByLens = {};
      var baseTotal = 0;
      var compoundedTotal = 0;

      LENSES.forEach(function(lens) {
        var base = delayDays * rates[lens];
        if (stage.id === "job_req_to_hiring" && lens === "labor") base += panelLaborCost;
        var comp = base * multiplier;
        baseByLens[lens] = base;
        compoundedByLens[lens] = comp;
        baseTotal += base;
        compoundedTotal += comp;
        totals.base_by_lens[lens] += base;
        totals.compounded_by_lens[lens] += comp;
      });

      var weightedComp = 0;
      var weightedBase = 0;
      LENSES.forEach(function(lens) {
        weightedBase += normalizedWeights[lens] * baseByLens[lens];
        weightedComp += normalizedWeights[lens] * compoundedByLens[lens];
      });

      totals.base_composite += weightedBase;
      totals.compounded_composite += weightedComp;

      stageResults.push({
        id: stage.id,
        name: stage.name,
        target_days: stage.target_days,
        actual_days: stage.actual_days,
        delay_days: delayDays,
        multiplier: multiplier,
        base_by_lens: baseByLens,
        compounded_by_lens: compoundedByLens,
        base_total: baseTotal,
        compounded_total: compoundedTotal,
        weighted_composite: weightedComp
      });
    });

    var doraOverlay = computeDoraOverlay(input, blendedDaily, cumulativeDelay);
    var doraWeighted = 0;
    LENSES.forEach(function(lens) {
      totals.base_by_lens[lens] += doraOverlay.base_by_lens[lens];
      totals.compounded_by_lens[lens] += doraOverlay.compounded_by_lens[lens];
      doraWeighted += normalizedWeights[lens] * doraOverlay.compounded_by_lens[lens];
    });
    totals.base_composite +=
      (normalizedWeights.labor * doraOverlay.base_by_lens.labor) +
      (normalizedWeights.revenue * doraOverlay.base_by_lens.revenue) +
      (normalizedWeights.opportunity * doraOverlay.base_by_lens.opportunity) +
      (normalizedWeights.goodwill * doraOverlay.base_by_lens.goodwill);
    totals.compounded_composite += doraWeighted;

    var core4 = computeCore4(stageResults, doraOverlay, totals.compounded_composite);

    var result = {
      metadata: { model_version: "v2", generated_at: new Date().toISOString() },
      assumptions: {
        salaries: salaries,
        blended_daily_loaded_cost: blendedDaily,
        panel_hours: panelHours,
        panel_labor_cost: panelLaborCost
      },
      stage_results: stageResults,
      dora_overlay: doraOverlay,
      core4_guidance: core4,
      totals: totals,
      sensitivity: []
    };

    if (!skipSensitivity) {
      result.sensitivity = computeSensitivity(input, normalizedWeights, totals.compounded_composite);
    }

    return result;
  }

  function computeSensitivity(input, normalizedWeights, baseline) {
    var rows = [];
    input.stages.forEach(function(stage, index) {
      var delay = Math.max(0, stage.actual_days - stage.target_days);
      if (delay <= 0) {
        rows.push({ stage_name: stage.name, savings_if_minus_1_day: 0 });
        return;
      }
      var cloned = clone(input);
      cloned.stages[index].actual_days = Math.max(cloned.stages[index].target_days, cloned.stages[index].actual_days - 1);
      var recomputed = computeResult(cloned, normalizedWeights, true);
      rows.push({
        stage_name: stage.name,
        savings_if_minus_1_day: baseline - recomputed.totals.compounded_composite
      });
    });
    return rows;
  }

  function renderResult(input, result) {
    $("summary-blended").textContent = money(result.assumptions.blended_daily_loaded_cost);
    $("summary-delay").textContent = String(result.totals.total_delay_days + result.dora_overlay.total_delay_days);
    $("summary-base").textContent = money(result.totals.base_composite);
    $("summary-compounded").textContent = money(result.totals.compounded_composite);
    $("summary-panel").textContent = money(result.assumptions.panel_labor_cost);

    var doraCompounded = 0;
    LENSES.forEach(function(lens) { doraCompounded += result.dora_overlay.compounded_by_lens[lens]; });
    $("summary-dora").textContent = money(doraCompounded);

    var topStage = "-";
    var max = -1;
    result.stage_results.forEach(function(stage) {
      if (stage.weighted_composite > max) {
        max = stage.weighted_composite;
        topStage = stage.name;
      }
    });
    $("summary-top-stage").textContent = topStage;

    var stageBody = $("stage-results-body");
    stageBody.innerHTML = "";
    result.stage_results.forEach(function(stage) {
      var tr = document.createElement("tr");
      tr.innerHTML = [
        "<td>" + stage.name + "</td>",
        "<td>" + stage.target_days + "</td>",
        "<td>" + stage.actual_days + "</td>",
        "<td>" + stage.delay_days + "</td>",
        "<td>" + fixed(stage.multiplier, 2) + "</td>",
        "<td>" + money(stage.base_total) + "</td>",
        "<td>" + money(stage.compounded_total) + "</td>",
        "<td>" + money(stage.weighted_composite) + "</td>"
      ].join("");
      stageBody.appendChild(tr);
    });

    var doraBody = $("dora-results-body");
    doraBody.innerHTML = "";
    [
      {
        signal: "Lead Time for Changes",
        value: fixed(input.dora.lead_time_actual_days, 1) + " days",
        target: fixed(input.dora.lead_time_target_days, 1) + " days",
        delay: fixed(result.dora_overlay.lead_delay_days, 1) + " days"
      },
      {
        signal: "Change Failure Rate",
        value: fixed(input.dora.cfr_actual_pct, 1) + "%",
        target: fixed(input.dora.cfr_target_pct, 1) + "%",
        delay: fixed(result.dora_overlay.excess_failures, 2) + " excess failures/month"
      },
      {
        signal: "MTTR",
        value: fixed(input.dora.mttr_actual_hours, 1) + " hours",
        target: fixed(input.dora.mttr_target_hours, 1) + " hours",
        delay: fixed(result.dora_overlay.mttr_delay_days, 1) + " days"
      },
      {
        signal: "DORA Total Cost Overlay",
        value: money(result.dora_overlay.base_by_lens.labor + result.dora_overlay.base_by_lens.revenue + result.dora_overlay.base_by_lens.opportunity + result.dora_overlay.base_by_lens.goodwill),
        target: "N/A",
        delay: money(result.dora_overlay.compounded_by_lens.labor + result.dora_overlay.compounded_by_lens.revenue + result.dora_overlay.compounded_by_lens.opportunity + result.dora_overlay.compounded_by_lens.goodwill)
      }
    ].forEach(function(row) {
      var tr = document.createElement("tr");
      tr.innerHTML = [
        "<td>" + row.signal + "</td>",
        "<td>" + row.value + "</td>",
        "<td>" + row.target + "</td>",
        "<td>" + row.delay + "</td>"
      ].join("");
      doraBody.appendChild(tr);
    });

    var lensBody = $("lens-results-body");
    lensBody.innerHTML = "";
    LENSES.forEach(function(lens) {
      var tr = document.createElement("tr");
      tr.innerHTML = [
        "<td>" + lens.charAt(0).toUpperCase() + lens.slice(1) + "</td>",
        "<td>" + money(result.totals.base_by_lens[lens]) + "</td>",
        "<td>" + money(result.totals.compounded_by_lens[lens]) + "</td>"
      ].join("");
      lensBody.appendChild(tr);
    });

    var core4 = $("core4-guidance");
    core4.innerHTML = "";
    result.core4_guidance.forEach(function(item) {
      var card = document.createElement("article");
      card.className = "devex-summary-card devex-core4-card";
      card.innerHTML = [
        "<strong>" + item.name + "</strong>",
        "<span>" + item.label + "</span>",
        "<small>Cost share: " + fixed(item.cost_share_pct, 1) + "%</small>",
        "<small>Health: " + fixed(item.health, 1) + "/100</small>",
        "<p>" + item.hint + "</p>"
      ].join("");
      core4.appendChild(card);
    });

    var sensitivityBody = $("sensitivity-results-body");
    sensitivityBody.innerHTML = "";
    result.sensitivity.forEach(function(row) {
      var tr = document.createElement("tr");
      tr.innerHTML = [
        "<td>" + row.stage_name + "</td>",
        "<td>" + money(row.savings_if_minus_1_day) + "</td>"
      ].join("");
      sensitivityBody.appendChild(tr);
    });

    $("json-snapshot").value = JSON.stringify({
      metadata: result.metadata,
      input: input,
      output: result
    }, null, 2);
  }

  function setError(message) { $("devex-errors").textContent = message || ""; }

  function updateHash(input) {
    var payload = { version: 2, input: input };
    history.replaceState(null, "", "#devex=" + base64Encode(JSON.stringify(payload)));
  }

  function parseHash() {
    if (!window.location.hash || !window.location.hash.startsWith("#devex=")) return null;
    try {
      var parsed = JSON.parse(base64Decode(window.location.hash.slice(7)));
      return parsed && parsed.input ? parsed.input : null;
    } catch (_err) {
      return null;
    }
  }

  function populateForm(input) {
    $("team_size").value = input.team_size;
    $("salary_min").value = input.salary_min;
    $("salary_max").value = input.salary_max;
    $("loaded_cost_multiplier").value = input.loaded_cost_multiplier;
    $("workdays_per_year").value = input.workdays_per_year;
    $("compounding_k").value = input.compounding_k;

    $("weight_labor").value = input.weights.labor;
    $("weight_revenue").value = input.weights.revenue;
    $("weight_opportunity").value = input.weights.opportunity;
    $("weight_goodwill").value = input.weights.goodwill;

    $("global_revenue_rate").value = input.global_rates.revenue;
    $("global_opportunity_rate").value = input.global_rates.opportunity;
    $("global_goodwill_rate").value = input.global_rates.goodwill;

    $("candidates").value = input.interview.candidates;
    $("interviewers").value = input.interview.interviewers;
    $("rounds").value = input.interview.rounds;
    $("hours_per_round").value = input.interview.hours_per_round;
    $("prep_debrief_hours_per_candidate").value = input.interview.prep_debrief_hours_per_candidate;

    if (input.dora) {
      $("dora_deployments_per_month").value = input.dora.deployments_per_month;
      $("dora_lead_time_actual_days").value = input.dora.lead_time_actual_days;
      $("dora_lead_time_target_days").value = input.dora.lead_time_target_days;
      $("dora_cfr_actual_pct").value = input.dora.cfr_actual_pct;
      $("dora_cfr_target_pct").value = input.dora.cfr_target_pct;
      $("dora_mttr_actual_hours").value = input.dora.mttr_actual_hours;
      $("dora_mttr_target_hours").value = input.dora.mttr_target_hours;
    }

    var stageById = {};
    (input.stages || []).forEach(function(stage) { stageById[stage.id] = stage; });
    document.querySelectorAll("[data-stage-id]").forEach(function(row) {
      var id = row.getAttribute("data-stage-id");
      var stage = stageById[id];
      if (!stage) return;
      row.querySelector('[data-field="target"]').value = stage.target_days;
      row.querySelector('[data-field="actual"]').value = stage.actual_days;
      row.querySelector('[data-field="labor_override"]').value = stage.overrides.labor == null ? "" : stage.overrides.labor;
      row.querySelector('[data-field="revenue_override"]').value = stage.overrides.revenue == null ? "" : stage.overrides.revenue;
      row.querySelector('[data-field="opportunity_override"]').value = stage.overrides.opportunity == null ? "" : stage.overrides.opportunity;
      row.querySelector('[data-field="goodwill_override"]').value = stage.overrides.goodwill == null ? "" : stage.overrides.goodwill;
    });
  }

  function calculate() {
    var input = collectInput();
    var validation = validateInput(input);
    if (!validation.valid) {
      setError(validation.errors.join(" "));
      return;
    }
    setError("");
    var result = computeResult(input, validation.normalized_weights, false);
    renderResult(input, result);
    updateHash(input);
  }

  function resetDefaults() {
    $("team_size").value = DEFAULTS.team_size;
    $("salary_min").value = DEFAULTS.salary_min;
    $("salary_max").value = DEFAULTS.salary_max;
    $("loaded_cost_multiplier").value = DEFAULTS.loaded_cost_multiplier;
    $("workdays_per_year").value = DEFAULTS.workdays_per_year;
    $("compounding_k").value = DEFAULTS.compounding_k;

    $("weight_labor").value = DEFAULTS.weights.labor;
    $("weight_revenue").value = DEFAULTS.weights.revenue;
    $("weight_opportunity").value = DEFAULTS.weights.opportunity;
    $("weight_goodwill").value = DEFAULTS.weights.goodwill;

    $("global_revenue_rate").value = DEFAULTS.global_rates.revenue;
    $("global_opportunity_rate").value = DEFAULTS.global_rates.opportunity;
    $("global_goodwill_rate").value = DEFAULTS.global_rates.goodwill;

    $("candidates").value = DEFAULTS.interview.candidates;
    $("interviewers").value = DEFAULTS.interview.interviewers;
    $("rounds").value = DEFAULTS.interview.rounds;
    $("hours_per_round").value = DEFAULTS.interview.hours_per_round;
    $("prep_debrief_hours_per_candidate").value = DEFAULTS.interview.prep_debrief_hours_per_candidate;

    $("dora_deployments_per_month").value = DEFAULTS.dora.deployments_per_month;
    $("dora_lead_time_actual_days").value = DEFAULTS.dora.lead_time_actual_days;
    $("dora_lead_time_target_days").value = DEFAULTS.dora.lead_time_target_days;
    $("dora_cfr_actual_pct").value = DEFAULTS.dora.cfr_actual_pct;
    $("dora_cfr_target_pct").value = DEFAULTS.dora.cfr_target_pct;
    $("dora_mttr_actual_hours").value = DEFAULTS.dora.mttr_actual_hours;
    $("dora_mttr_target_hours").value = DEFAULTS.dora.mttr_target_hours;

    document.querySelectorAll("[data-stage-id]").forEach(function(row) {
      row.querySelector('[data-field="labor_override"]').value = "";
      row.querySelector('[data-field="revenue_override"]').value = "";
      row.querySelector('[data-field="opportunity_override"]').value = "";
      row.querySelector('[data-field="goodwill_override"]').value = "";
    });
  }

  function copySnapshot() {
    var text = $("json-snapshot").value;
    if (!text) {
      setError("No snapshot available to copy.");
      return;
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text)
        .then(function() { setError("Snapshot copied to clipboard."); })
        .catch(function() { setError("Unable to copy snapshot. Please copy manually."); });
    } else {
      $("json-snapshot").focus();
      $("json-snapshot").select();
      setError("Clipboard API unavailable. Snapshot selected for manual copy.");
    }
  }

  function importSnapshot() {
    var raw = $("json-snapshot").value;
    if (!raw.trim()) {
      setError("Paste a snapshot payload before importing.");
      return;
    }
    try {
      var parsed = JSON.parse(raw);
      var input = parsed.input ? parsed.input : parsed;
      if (!input || !input.stages || !input.weights || !input.global_rates) {
        setError("Invalid snapshot payload.");
        return;
      }
      populateForm(input);
      calculate();
    } catch (_err) {
      setError("Invalid JSON snapshot.");
    }
  }

  function init() {
    var form = $("devex-calculator-form");
    if (!form) return;

    form.addEventListener("submit", function(event) {
      event.preventDefault();
      calculate();
    });

    $("reset-defaults").addEventListener("click", function() {
      resetDefaults();
      calculate();
    });
    $("copy-json").addEventListener("click", copySnapshot);
    $("import-json").addEventListener("click", importSnapshot);

    var hashInput = parseHash();
    if (hashInput) populateForm(hashInput);
    calculate();
  }

  document.addEventListener("DOMContentLoaded", init);
})();
