(function() {
  "use strict";

  var LENSES = ["labor", "revenue", "opportunity", "goodwill"];

  var STAGE_SCHEMA = [
    { id: "zero_to_need", name: "Zero -> Identified Need for Developer Role", target_days: 5, actual_days: 5, fixed: true },
    { id: "need_to_req", name: "Identified Need -> Job Req", target_days: 3, actual_days: 3, fixed: true },
    { id: "job_req_to_hiring", name: "Job Req -> Hiring Process", target_days: 20, actual_days: 20, fixed: true },
    { id: "hiring_to_onboarding", name: "Hiring Process -> Onboarding", target_days: 5, actual_days: 5, fixed: true },
    { id: "onboarding_to_functional", name: "Onboarding -> Functional", target_days: 3, actual_days: 3, fixed: true },
    { id: "functional_to_operational", name: "Functional -> Operational", target_days: 20, actual_days: 20, fixed: true },
    { id: "operational_to_independent", name: "Operational -> Independent", target_days: 45, actual_days: 45, fixed: true },
    { id: "independent_to_leverage", name: "Independent -> Leverage", target_days: 90, actual_days: 90, fixed: true },
    { id: "employment_microloop_friction", name: "Employment Microloop Friction", target_days: 10, actual_days: 10, fixed: true },
    { id: "retention_to_exit", name: "Retention Risk -> Exit", target_days: 0, actual_days: 0, fixed: true },
    { id: "exit_to_backfill", name: "Exit -> Backfill Complete", target_days: 30, actual_days: 30, fixed: true }
  ];

  var STAGE_NAMES = STAGE_SCHEMA.reduce(function(map, stage) {
    map[stage.id] = stage.name;
    return map;
  }, {});

  var DEFAULTS = {
    team_size: 10,
    salary_min: 50000,
    salary_max: 100000,
    loaded_cost_multiplier: 1.3,
    workdays_per_year: 260,
    compounding_k: 0.01,
    include_dora_in_total: false,
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
  function sumLensValues(obj) {
    return LENSES.reduce(function(sum, lens) { return sum + toNumber(obj[lens], 0); }, 0);
  }

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

  function defaultStages() {
    return STAGE_SCHEMA.map(function(stage) {
      return {
        id: stage.id,
        name: stage.name,
        target_days: stage.target_days,
        actual_days: stage.actual_days,
        fixed: true,
        overrides: { labor: null, revenue: null, opportunity: null, goodwill: null }
      };
    });
  }

  function normalizeStage(stage, index) {
    var fallbackId = "custom_" + (index + 1);
    var id = (stage && stage.id) ? String(stage.id).trim() : fallbackId;
    var name = (stage && stage.name) ? String(stage.name).trim() : (STAGE_NAMES[id] || ("Custom Stage " + (index + 1)));
    var overrides = (stage && stage.overrides) ? stage.overrides : {};
    var schemaMatch = STAGE_SCHEMA.find(function(s) { return s.id === id; });
    return {
      id: id || fallbackId,
      name: name,
      target_days: toNumber(stage && stage.target_days, schemaMatch ? schemaMatch.target_days : 0),
      actual_days: toNumber(stage && stage.actual_days, schemaMatch ? schemaMatch.actual_days : 0),
      fixed: Boolean(schemaMatch && schemaMatch.fixed),
      overrides: {
        labor: overrides.labor == null ? null : toNumber(overrides.labor, 0),
        revenue: overrides.revenue == null ? null : toNumber(overrides.revenue, 0),
        opportunity: overrides.opportunity == null ? null : toNumber(overrides.opportunity, 0),
        goodwill: overrides.goodwill == null ? null : toNumber(overrides.goodwill, 0)
      }
    };
  }

  function normalizeStages(stages) {
    var raw = Array.isArray(stages) && stages.length ? stages : defaultStages();
    return raw.map(function(stage, index) { return normalizeStage(stage, index); });
  }

  function createStageCellInput(value, field, step) {
    var input = document.createElement("input");
    input.setAttribute("data-field", field);
    input.type = "number";
    input.min = "0";
    input.step = step || "1";
    input.required = field === "target" || field === "actual";
    if (value != null) input.value = String(value);
    return input;
  }

  function renderStageRows(stages) {
    var tbody = $("lifecycle-stage-inputs-body");
    if (!tbody) return;
    tbody.innerHTML = "";
    normalizeStages(stages).forEach(function(stage, index) {
      var row = document.createElement("tr");
      row.setAttribute("data-stage-id", stage.id);
      row.setAttribute("data-stage-fixed", stage.fixed ? "1" : "0");

      var nameCell = document.createElement("td");
      if (stage.fixed) {
        nameCell.textContent = stage.name;
      } else {
        var nameInput = document.createElement("input");
        nameInput.type = "text";
        nameInput.setAttribute("data-field", "name");
        nameInput.value = stage.name || ("Custom Stage " + (index + 1));
        nameInput.required = true;
        nameCell.appendChild(nameInput);
      }
      row.appendChild(nameCell);

      ["target", "actual"].forEach(function(field) {
        var td = document.createElement("td");
        td.appendChild(createStageCellInput(stage[field + "_days"], field, "1"));
        row.appendChild(td);
      });

      ["labor_override", "revenue_override", "opportunity_override", "goodwill_override"].forEach(function(field) {
        var td = document.createElement("td");
        var key = field.replace("_override", "");
        td.appendChild(createStageCellInput(stage.overrides[key], field, "10"));
        row.appendChild(td);
      });

      var actionCell = document.createElement("td");
      if (!stage.fixed) {
        var removeButton = document.createElement("button");
        removeButton.type = "button";
        removeButton.className = "video-button devex-row-action";
        removeButton.setAttribute("data-action", "remove-stage");
        removeButton.textContent = "Remove";
        actionCell.appendChild(removeButton);
      } else {
        actionCell.textContent = "-";
      }
      row.appendChild(actionCell);
      tbody.appendChild(row);
    });
  }

  function readStageRows() {
    var rows = document.querySelectorAll("#lifecycle-stage-inputs-body [data-stage-id]");
    var stages = [];
    rows.forEach(function(row) {
      function readField(name) {
        var input = row.querySelector("[data-field=\"" + name + "\"]");
        return input ? input.value : "";
      }
      var id = row.getAttribute("data-stage-id");
      var fixed = row.getAttribute("data-stage-fixed") === "1";
      var name = fixed ? (STAGE_NAMES[id] || id) : readField("name");
      stages.push({
        id: id,
        name: name,
        fixed: fixed,
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
      include_dora_in_total: $("include_dora_in_total").checked,
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

  function normalizeInputModel(input) {
    var model = clone(input || {});
    model.team_size = toNumber(model.team_size, DEFAULTS.team_size);
    model.salary_min = toNumber(model.salary_min, DEFAULTS.salary_min);
    model.salary_max = toNumber(model.salary_max, DEFAULTS.salary_max);
    model.loaded_cost_multiplier = toNumber(model.loaded_cost_multiplier, DEFAULTS.loaded_cost_multiplier);
    model.workdays_per_year = toNumber(model.workdays_per_year, DEFAULTS.workdays_per_year);
    model.compounding_k = toNumber(model.compounding_k, DEFAULTS.compounding_k);
    model.include_dora_in_total = Boolean(model.include_dora_in_total);

    model.weights = model.weights || clone(DEFAULTS.weights);
    model.global_rates = model.global_rates || clone(DEFAULTS.global_rates);
    model.interview = model.interview || clone(DEFAULTS.interview);
    model.dora = model.dora || clone(DEFAULTS.dora);
    model.stages = normalizeStages(model.stages);
    return model;
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
      if (!stage.name || !String(stage.name).trim()) {
        errors.push("Each stage must have a name.");
      }
    });
    var seenStageIds = {};
    input.stages.forEach(function(stage) {
      if (seenStageIds[stage.id]) errors.push("Stage IDs must be unique. Duplicate found for " + stage.id + ".");
      seenStageIds[stage.id] = true;
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

  function computeCore4(stageResults, doraOverlay, totalComposite, includeDoraInTotal) {
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
          (includeDoraInTotal ? (sumLensValues(doraOverlay.lead_base_by_lens) * doraOverlay.multiplier) : 0),
        hint: "Reduce wait states in review/CI/deploy loops and tighten feedback windows."
      },
      {
        name: "Core 4: Retention and Continuity",
        value: stageCost("retention_to_exit") + stageCost("exit_to_backfill") +
          (includeDoraInTotal ? (sumLensValues(doraOverlay.recovery_base_by_lens) * doraOverlay.multiplier) : 0),
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

  function computeGoldenSignals(stageResults) {
    var phases = [
      {
        name: "Planning and Staffing",
        stage_ids: ["zero_to_need", "need_to_req", "job_req_to_hiring"],
        focus: "Latency: role-to-hire time. Errors: role mismatch/rework. Traffic: requisition and candidate flow. Saturation: interviewer and hiring manager load."
      },
      {
        name: "Enablement and Onboarding",
        stage_ids: ["hiring_to_onboarding", "onboarding_to_functional", "functional_to_operational"],
        focus: "Latency: time to first functional contribution. Errors: access/provisioning failures. Traffic: onboarding volume. Saturation: IT and mentor capacity."
      },
      {
        name: "Flow and Feedback",
        stage_ids: ["operational_to_independent", "independent_to_leverage", "employment_microloop_friction"],
        focus: "Latency: PR/CI/release wait time. Errors: failed changes and rework loops. Traffic: change throughput. Saturation: CI, review queues, and handoff bottlenecks."
      },
      {
        name: "Retention and Continuity",
        stage_ids: ["retention_to_exit", "exit_to_backfill"],
        focus: "Latency: backfill and knowledge transfer time. Errors: continuity and quality degradation. Traffic: attrition/backfill events. Saturation: load shifted to remaining team."
      }
    ];

    return phases.map(function(phase) {
      var relevant = stageResults.filter(function(stage) { return phase.stage_ids.indexOf(stage.id) !== -1; });
      var latency = relevant.reduce(function(sum, stage) { return sum + stage.delay_days; }, 0);
      var cost = relevant.reduce(function(sum, stage) { return sum + stage.weighted_composite; }, 0);
      var status = "Healthy";
      if (latency > 10 || cost > 25000) status = "At risk";
      else if (latency > 3 || cost > 5000) status = "Watch";

      return {
        phase_name: phase.name,
        latency_days: latency,
        weighted_friction_cost: cost,
        focus: phase.focus,
        status: status
      };
    });
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
    var lifecycleTotals = {
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
      lifecycleTotals.total_delay_days += delayDays;
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
        lifecycleTotals.base_by_lens[lens] += base;
        lifecycleTotals.compounded_by_lens[lens] += comp;
      });

      var weightedComp = 0;
      var weightedBase = 0;
      LENSES.forEach(function(lens) {
        weightedBase += normalizedWeights[lens] * baseByLens[lens];
        weightedComp += normalizedWeights[lens] * compoundedByLens[lens];
      });

      lifecycleTotals.base_composite += weightedBase;
      lifecycleTotals.compounded_composite += weightedComp;

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
    var doraWeightedBase = 0;
    var doraWeightedCompounded = 0;
    LENSES.forEach(function(lens) {
      doraWeightedBase += normalizedWeights[lens] * doraOverlay.base_by_lens[lens];
      doraWeightedCompounded += normalizedWeights[lens] * doraOverlay.compounded_by_lens[lens];
    });

    var effectiveTotals = {
      base_by_lens: clone(lifecycleTotals.base_by_lens),
      compounded_by_lens: clone(lifecycleTotals.compounded_by_lens),
      base_composite: lifecycleTotals.base_composite,
      compounded_composite: lifecycleTotals.compounded_composite
    };

    if (input.include_dora_in_total) {
      LENSES.forEach(function(lens) {
        effectiveTotals.base_by_lens[lens] += doraOverlay.base_by_lens[lens];
        effectiveTotals.compounded_by_lens[lens] += doraOverlay.compounded_by_lens[lens];
      });
      effectiveTotals.base_composite += doraWeightedBase;
      effectiveTotals.compounded_composite += doraWeightedCompounded;
    }

    var core4 = computeCore4(stageResults, doraOverlay, effectiveTotals.compounded_composite, input.include_dora_in_total);
    var goldenSignals = computeGoldenSignals(stageResults);

    var result = {
      metadata: { model_version: "v3", generated_at: new Date().toISOString() },
      assumptions: {
        salaries: salaries,
        blended_daily_loaded_cost: blendedDaily,
        panel_hours: panelHours,
        panel_labor_cost: panelLaborCost,
        include_dora_in_total: input.include_dora_in_total
      },
      stage_results: stageResults,
      dora_overlay: doraOverlay,
      core4_guidance: core4,
      golden_signals: goldenSignals,
      totals: {
        lifecycle_base_by_lens: lifecycleTotals.base_by_lens,
        lifecycle_compounded_by_lens: lifecycleTotals.compounded_by_lens,
        lifecycle_base_composite: lifecycleTotals.base_composite,
        lifecycle_compounded_composite: lifecycleTotals.compounded_composite,
        lifecycle_delay_days: lifecycleTotals.total_delay_days,
        dora_base_by_lens: doraOverlay.base_by_lens,
        dora_compounded_by_lens: doraOverlay.compounded_by_lens,
        dora_weighted_base: doraWeightedBase,
        dora_weighted_compounded: doraWeightedCompounded,
        dora_delay_days: doraOverlay.total_delay_days,
        effective_base_by_lens: effectiveTotals.base_by_lens,
        effective_compounded_by_lens: effectiveTotals.compounded_by_lens,
        effective_base_composite: effectiveTotals.base_composite,
        effective_compounded_composite: effectiveTotals.compounded_composite
      },
      sensitivity: []
    };

    if (!skipSensitivity) {
      result.sensitivity = computeSensitivity(input, normalizedWeights, effectiveTotals.compounded_composite);
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
        savings_if_minus_1_day: baseline - recomputed.totals.effective_compounded_composite
      });
    });
    return rows;
  }

  function renderResult(input, result) {
    $("summary-blended").textContent = money(result.assumptions.blended_daily_loaded_cost);
    $("summary-delay").textContent = fixed(result.totals.lifecycle_delay_days, 1);
    $("summary-base").textContent = money(result.totals.lifecycle_compounded_composite);
    $("summary-compounded").textContent = money(result.totals.effective_compounded_composite);
    $("summary-panel").textContent = money(result.assumptions.panel_labor_cost);

    var doraCompounded = 0;
    LENSES.forEach(function(lens) { doraCompounded += result.dora_overlay.compounded_by_lens[lens]; });
    $("summary-dora").textContent = money(doraCompounded);
    $("summary-dora-delay").textContent = fixed(result.totals.dora_delay_days, 1);

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
        "<td>" + money(result.totals.effective_base_by_lens[lens]) + "</td>",
        "<td>" + money(result.totals.effective_compounded_by_lens[lens]) + "</td>"
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

    var goldenSignalsBody = $("golden-signals-body");
    goldenSignalsBody.innerHTML = "";
    result.golden_signals.forEach(function(row) {
      var statusClass = row.status === "At risk" ? "devex-status-risk" : (row.status === "Watch" ? "devex-status-watch" : "devex-status-healthy");
      var tr = document.createElement("tr");
      tr.innerHTML = [
        "<td>" + row.phase_name + "</td>",
        "<td>" + fixed(row.latency_days, 1) + "</td>",
        "<td>" + money(row.weighted_friction_cost) + "</td>",
        "<td>" + row.focus + "</td>",
        "<td><span class=\"devex-status " + statusClass + "\">" + row.status + "</span></td>"
      ].join("");
      goldenSignalsBody.appendChild(tr);
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
    var payload = { version: 3, input: input };
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
    var normalized = normalizeInputModel(input);
    input = normalized;
    $("team_size").value = input.team_size;
    $("salary_min").value = input.salary_min;
    $("salary_max").value = input.salary_max;
    $("loaded_cost_multiplier").value = input.loaded_cost_multiplier;
    $("workdays_per_year").value = input.workdays_per_year;
    $("compounding_k").value = input.compounding_k;
    $("include_dora_in_total").checked = Boolean(input.include_dora_in_total);

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
    renderStageRows(input.stages);
  }

  function calculate() {
    var input = normalizeInputModel(collectInput());
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

  function nextCustomStageId(stages) {
    var max = 0;
    stages.forEach(function(stage) {
      var match = String(stage.id || "").match(/^custom_(\d+)$/);
      if (match) max = Math.max(max, toNumber(match[1], 0));
    });
    return "custom_" + (max + 1);
  }

  function addCustomStage() {
    var stages = normalizeStages(readStageRows());
    var nextId = nextCustomStageId(stages);
    stages.push({
      id: nextId,
      name: "Custom Stage " + nextId.split("_")[1],
      target_days: 0,
      actual_days: 0,
      fixed: false,
      overrides: { labor: null, revenue: null, opportunity: null, goodwill: null }
    });
    renderStageRows(stages);
  }

  function removeCustomStage(button) {
    var row = button.closest("[data-stage-id]");
    if (!row) return;
    var stageId = row.getAttribute("data-stage-id");
    var stages = normalizeStages(readStageRows()).filter(function(stage) { return stage.id !== stageId; });
    renderStageRows(stages);
  }

  function resetDefaults() {
    populateForm({
      team_size: DEFAULTS.team_size,
      salary_min: DEFAULTS.salary_min,
      salary_max: DEFAULTS.salary_max,
      loaded_cost_multiplier: DEFAULTS.loaded_cost_multiplier,
      workdays_per_year: DEFAULTS.workdays_per_year,
      compounding_k: DEFAULTS.compounding_k,
      include_dora_in_total: DEFAULTS.include_dora_in_total,
      weights: clone(DEFAULTS.weights),
      global_rates: clone(DEFAULTS.global_rates),
      interview: clone(DEFAULTS.interview),
      dora: clone(DEFAULTS.dora),
      stages: defaultStages()
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
      var input = normalizeInputModel(parsed.input ? parsed.input : parsed);
      if (!input || !input.weights || !input.global_rates) {
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

    renderStageRows(defaultStages());

    form.addEventListener("submit", function(event) {
      event.preventDefault();
      calculate();
    });

    $("reset-defaults").addEventListener("click", function() {
      resetDefaults();
      calculate();
    });
    $("add-custom-stage").addEventListener("click", addCustomStage);
    $("lifecycle-stage-inputs-body").addEventListener("click", function(event) {
      var target = event.target;
      if (target && target.getAttribute("data-action") === "remove-stage") {
        removeCustomStage(target);
      }
    });
    $("copy-json").addEventListener("click", copySnapshot);
    $("import-json").addEventListener("click", importSnapshot);

    var hashInput = parseHash();
    if (hashInput) populateForm(hashInput);
    calculate();
  }

  document.addEventListener("DOMContentLoaded", init);
})();
