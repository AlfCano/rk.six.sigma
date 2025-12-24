local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.six.sigma",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin for Advanced Industrial Statistics and Six Sigma. Includes Gage R&R, Attribute Agreement Analysis, and Process Capability.",
      version = "0.0.1", # Frozen
      url = "https://github.com/AlfCano/rk.six.sigma",
      license = "GPL (>= 3)"
    )
  )

  # Menu Hierarchy
  common_hierarchy <- list("analysis", "Industrial Stats", "Six Sigma")

  # =========================================================================================
  # JS Helper
  # =========================================================================================
  js_parse_helper <- "
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        return fullPath;
    }

    function getColName(fullPath) {
        if (!fullPath) return '';
        if (fullPath.indexOf('$') > -1) {
            return fullPath.split('$')[1];
        } else if (fullPath.indexOf('[[') > -1) {
            var inner = fullPath.split('[[')[1];
            return inner.replace(']]', '').replace(/[\"']/g, '');
        }
        return fullPath;
    }
  "

  # =========================================================================================
  # MAIN COMPONENT: Gage R and R
  # =========================================================================================

  help_rr <- rk.rkh.doc(
    title = rk.rkh.title(text = "Gage R and R Study (Crossed)"),
    summary = rk.rkh.summary(text = "Perform a Crossed Gage Repeatability and Reproducibility study using SixSigma::ss.rr."),
    usage = rk.rkh.usage(text = "Select the dataframe containing your study data. Specify the columns for Measurement, Part, and Operator.")
  )

  rr_selector <- rk.XML.varselector(id.name = "rr_selector")

  rr_data <- rk.XML.varslot(label = "Study Dataframe", source = "rr_selector", classes = "data.frame", required = TRUE, id.name = "rr_data")
  rr_meas <- rk.XML.varslot(label = "Measurement (Response)", source = "rr_selector", required = TRUE, id.name = "rr_meas")
  rr_part <- rk.XML.varslot(label = "Part ID", source = "rr_selector", required = TRUE, id.name = "rr_part")
  rr_oper <- rk.XML.varslot(label = "Operator/Appraiser ID", source = "rr_selector", required = TRUE, id.name = "rr_oper")

  rr_sigma <- rk.XML.spinbox(label = "Sigma Multiplier (Study Var)", min = 1, initial = 6, id.name = "rr_sigma")
  rr_tol <- rk.XML.input(label = "Process Tolerance (Optional, for %P/T)", id.name = "rr_tol")
  rr_plot <- rk.XML.cbox(label = "Plot Standard R&R Graphs", value = "1", chk = TRUE, id.name = "rr_plot")

  # Handshake Name: gage_rr_res
  rr_save <- rk.XML.saveobj(label = "Save Result Object", chk = TRUE, initial = "gage_rr_res", id.name = "rr_save")
  rr_preview <- rk.XML.preview(mode = "plot")

  dialog_rr <- rk.XML.dialog(
    label = "Gage R and R (Crossed)",
    child = rk.XML.row(
        rr_selector,
        rk.XML.col(
            rr_data,
            rk.XML.frame(rr_meas, rr_part, rr_oper, label = "Variables"),
            rk.XML.frame(rr_sigma, rr_tol, label = "Settings"),
            rr_plot,
            rr_save,
            rr_preview
        )
    )
  )

  js_body_rr <- '
    var data = getValue("rr_data");
    var meas = getColName(getValue("rr_meas"));
    var part = getColName(getValue("rr_part"));
    var oper = getColName(getValue("rr_oper"));
    var sig = getValue("rr_sigma");
    var tol = getValue("rr_tol");
    var plot = getValue("rr_plot");

    var args = "var = " + meas + ", part = " + part + ", appr = " + oper + ", data = " + data;
    args += ", sigma = " + sig;

    if (tol != "") {
        args += ", tolerance = " + tol;
    }

    args += ", main = \\"Gage R&R Study\\"";
  '

  js_calc_rr <- paste0(js_parse_helper, js_body_rr, '
    echo("gage_rr_res <- SixSigma::ss.rr(" + args + ", print_plot = FALSE)\\n");
  ')

  js_print_rr <- paste0(js_parse_helper, js_body_rr, '
    echo("require(SixSigma)\\n");
    echo("rk.header(\\"Gage R&R (Crossed) Results\\", level=3);\\n");

    echo("rk.header(\\"Complete Model (with interaction)\\", level=4);\\n");
    echo("rk.results(as.data.frame(gage_rr_res$anovaTable[[1]]))\\n");

    echo("rk.header(\\"Reduced Model (without interaction)\\", level=4);\\n");
    echo("rk.results(as.data.frame(gage_rr_res$anovaRed[[1]]))\\n");

    echo("rk.header(\\"Variance Components\\", level=4);\\n");
    echo("rk.results(as.data.frame(gage_rr_res$varComp))\\n");

    echo("rk.header(\\"Study Variation\\", level=4);\\n");
    echo("rk.results(as.data.frame(gage_rr_res$studyVar))\\n");

    echo("rk.print(paste(\\"<b>Number of Distinct Categories =</b>\\", gage_rr_res$ncat))\\n");

    if (plot == "1") {
        echo("rk.graph.on()\\n");
        echo("SixSigma::ss.rr(" + args + ", print_plot = TRUE)\\n");
        echo("rk.graph.off()\\n");
    }
  ')

  js_preview_rr <- paste0(js_parse_helper, js_body_rr, '
    echo("require(SixSigma)\\n");
    echo("SixSigma::ss.rr(" + args + ", print_plot = TRUE)\\n");
  ')

  component_rr <- rk.plugin.component(
    "Gage R and R",
    xml = list(dialog = dialog_rr),
    js = list(require="SixSigma", calculate=js_calc_rr, printout=js_print_rr, preview=js_preview_rr),
    hierarchy = common_hierarchy,
    rkh = list(help = help_rr)
  )

  # =========================================================================================
  # COMPONENT 2: Attribute Agreement Analysis
  # =========================================================================================

  help_attr <- rk.rkh.doc(
    title = rk.rkh.title(text = "Attribute Agreement Analysis"),
    summary = rk.rkh.summary(text = "Perform agreement analysis for attribute data (Pass/Fail or Ordinal) using Fleiss' Kappa."),
    usage = rk.rkh.usage(text = "Input data in 'Long' format (Sample, Appraiser, Rating). The plugin converts it to a matrix and calculates Fleiss' Kappa.")
  )

  attr_selector <- rk.XML.varselector(id.name = "attr_selector")

  attr_data <- rk.XML.varslot(label = "Dataframe", source = "attr_selector", classes = "data.frame", required = TRUE, id.name = "attr_data")
  attr_sample <- rk.XML.varslot(label = "Sample/Subject ID", source = "attr_selector", required = TRUE, id.name = "attr_sample")
  attr_appr <- rk.XML.varslot(label = "Appraiser/Rater", source = "attr_selector", required = TRUE, id.name = "attr_appr")
  attr_rating <- rk.XML.varslot(label = "Rating/Outcome", source = "attr_selector", required = TRUE, id.name = "attr_rating")

  # Handshake Name: attr_agreement_res
  attr_save <- rk.XML.saveobj(label = "Save Result Object", chk = TRUE, initial = "attr_agreement_res", id.name = "attr_save")

  dialog_attr <- rk.XML.dialog(
    label = "Attribute Agreement Analysis",
    child = rk.XML.row(
        attr_selector,
        rk.XML.col(
            attr_data,
            rk.XML.frame(attr_sample, attr_appr, attr_rating, label = "Variables (Long Format)"),
            attr_save,
            rk.XML.text("Calculates Fleiss' Kappa for multiple raters.")
        )
    )
  )

  js_body_attr <- '
    var df = getValue("attr_data");
    var s_col = getColName(getValue("attr_sample"));
    var a_col = getColName(getValue("attr_appr"));
    var r_col = getColName(getValue("attr_rating"));
  '

  js_calc_attr <- paste0(js_parse_helper, js_body_attr, '
    echo("# Reshape data to Matrix (Subjects x Raters)\\n");
    echo("attr_wide <- reshape(data = " + df + "[, c(\\"" + s_col + "\\", \\"" + a_col + "\\", \\"" + r_col + "\\")], \\n");
    echo("                     idvar = \\"" + s_col + "\\", timevar = \\"" + a_col + "\\", direction = \\"wide\\")\\n");
    echo("rownames(attr_wide) <- attr_wide[[1]]\\n");
    echo("attr_wide <- attr_wide[, -1] # Remove ID column\\n");
    echo("attr_matrix <- as.matrix(attr_wide)\\n");

    echo("attr_agreement_res <- irr::kappam.fleiss(attr_matrix)\\n");
  ')

  js_print_attr <- paste0(js_parse_helper, js_body_attr, '
    var save_name = getValue("attr_save.objectname");

    echo("require(irr)\\n");
    echo("rk.header(\\"Attribute Agreement Analysis (Fleiss Kappa)\\", level=3);\\n");
    echo("rk.print(\\"Data reshaped from: " + df + "\\")\\n");

    echo("irr_summary <- data.frame(Subjects = attr_agreement_res$subjects, Raters = attr_agreement_res$raters, Kappa = round(attr_agreement_res$value, 3), z = round(attr_agreement_res$statistic, 3), p.value = attr_agreement_res$p.value)\\n");
    echo("rk.results(irr_summary)\\n");

    echo("rk.print(paste(\\"Interpretation: < 0.40 Poor, 0.40-0.75 Fair/Good, > 0.75 Excellent\\"))\\n");

    if (save_name != "") {
        echo("assign(\\\"" + save_name + "\\\", attr_agreement_res, envir = .GlobalEnv)\\n");
    }
  ')

  component_attr <- rk.plugin.component(
    "Attribute Agreement",
    xml = list(dialog = dialog_attr),
    js = list(require="irr", calculate=js_calc_attr, printout=js_print_attr),
    hierarchy = common_hierarchy,
    rkh = list(help = help_attr)
  )

  # =========================================================================================
  # COMPONENT 3: Process Capability
  # =========================================================================================

  help_cap <- rk.rkh.doc(
    title = rk.rkh.title(text = "Process Capability Analysis"),
    summary = rk.rkh.summary(text = "Calculate capability indices (Cp, Cpk, Pp, Ppk) for Normal and Non-Normal distributions (Weibull, Lognormal)."),
    usage = rk.rkh.usage(text = "Select a numeric data vector. Specify LSL, USL, and Target. Choose distribution.")
  )

  cap_selector <- rk.XML.varselector(id.name = "cap_selector")

  cap_var <- rk.XML.varslot(label = "Measurement Data (Numeric Vector)", source = "cap_selector", required = TRUE, id.name = "cap_var")

  cap_lsl <- rk.XML.input(label = "Lower Spec Limit (LSL)", id.name = "cap_lsl")
  cap_usl <- rk.XML.input(label = "Upper Spec Limit (USL)", id.name = "cap_usl")
  cap_target <- rk.XML.input(label = "Target (Optional)", id.name = "cap_target")

  cap_dist <- rk.XML.dropdown(label = "Distribution", options = list(
      "Normal" = list(val = "norm", chk = TRUE),
      "Weibull" = list(val = "weibull"),
      "Lognormal" = list(val = "lnorm"),
      "Exponential" = list(val = "exp")
  ), id.name = "cap_dist")

  # Handshake Name: capability_res
  cap_save <- rk.XML.saveobj(label = "Save Result Object", chk = TRUE, initial = "capability_res", id.name = "cap_save")
  cap_preview <- rk.XML.preview(mode = "plot")

  dialog_cap <- rk.XML.dialog(
    label = "Process Capability",
    child = rk.XML.row(
        cap_selector,
        rk.XML.col(
            cap_var,
            rk.XML.frame(cap_lsl, cap_usl, cap_target, label = "Specifications"),
            cap_dist,
            cap_save,
            cap_preview
        )
    )
  )

  js_body_cap <- '
    var x = getValue("cap_var");
    var lsl = getValue("cap_lsl");
    var usl = getValue("cap_usl");
    var target = getValue("cap_target");
    var dist = getValue("cap_dist");

    if (lsl == "") lsl = "NA";
    if (usl == "") usl = "NA";
    if (target == "") target = "NA";
  '

  js_calc_cap <- paste0(js_parse_helper, js_body_cap, '
    if (dist == "norm") {
        echo("capability_res <- SixSigma::ss.study.ca(" + x + ", LSL=" + lsl + ", USL=" + usl + ", Target=" + target + ")\\n");
    } else {
        echo("# Fit Distribution: " + dist + "\\n");
        echo("fit <- MASS::fitdistr(" + x + ", densfun = \\"" + dist + "\\")\\n");

        echo("q_lower <- do.call(\\"q" + dist + "\\", c(list(p=0.00135), as.list(fit$estimate)))\\n");
        echo("q_upper <- do.call(\\"q" + dist + "\\", c(list(p=0.99865), as.list(fit$estimate)))\\n");
        echo("q_med   <- do.call(\\"q" + dist + "\\", c(list(p=0.5), as.list(fit$estimate)))\\n");

        echo("lsl <- " + lsl + "\\n");
        echo("usl <- " + usl + "\\n");
        echo("pp <- (q_upper - q_lower) / 6\\n");
        echo("ppk_l <- if(!is.na(lsl)) (q_med - lsl) / (q_med - q_lower) else NA\\n");
        echo("ppk_u <- if(!is.na(usl)) (usl - q_med) / (q_upper - q_med) else NA\\n");
        echo("ppk <- min(ppk_l, ppk_u, na.rm=TRUE)\\n");

        echo("capability_res <- fit\\n");
    }
  ')

  # PRINT: Updated with dynamic ylim calculation for better graph scaling
  js_print_cap <- paste0(js_parse_helper, js_body_cap, '
    var save_name = getValue("cap_save.objectname");

    echo("rk.header(\\"Process Capability Analysis (" + dist + ")\\", level=3);\\n");

    if (dist == "norm") {
        echo("print(capability_res)\\n");
        echo("rk.graph.on()\\n");
        echo("plot(capability_res)\\n");
        echo("rk.graph.off()\\n");
    } else {
        echo("rk.header(\\"Distribution Parameters\\", level=4);\\n");
        echo("rk.results(as.data.frame(t(capability_res$estimate)))\\n");

        echo("rk.header(\\"Capability Indices (Quantile Method)\\", level=4);\\n");
        echo("res_tab <- data.frame(Index = c(\\"Pp (Overall)\\", \\"Ppk (Overall)\\"), Value = round(c(pp, ppk), 3))\\n");
        echo("rk.results(res_tab)\\n");

        echo("rk.graph.on()\\n");
        // NEW: Calculate max height for Y-axis scaling
        echo("h <- hist(" + x + ", plot=FALSE)\\n");
        echo("d <- density(" + x + ")\\n");
        echo("y_max <- max(h$density, d$y) * 1.2\\n");

        // Plot with custom ylim
        echo("hist(" + x + ", freq=FALSE, ylim=c(0, y_max), main=\\"Capability Histogram (" + dist + ")\\")\\n");
        echo("lines(density(" + x + "), lty=2)\\n");
        echo("curve(do.call(\\"d" + dist + "\\", c(list(x), as.list(capability_res$estimate))), add=TRUE, col=\\"red\\", lwd=2)\\n");
        echo("if(!is.na(" + lsl + ")) abline(v=" + lsl + ", col=\\"red\\", lty=3, lwd=2)\\n");
        echo("if(!is.na(" + usl + ")) abline(v=" + usl + ", col=\\"red\\", lty=3, lwd=2)\\n");
        echo("rk.graph.off()\\n");
    }

    if (save_name != "") {
        echo("assign(\\\"" + save_name + "\\\", capability_res, envir = .GlobalEnv)\\n");
    }
  ')

  js_preview_cap <- paste0(js_parse_helper, js_body_cap, '
    if (dist == "norm") {
         echo("SixSigma::ss.study.ca(" + x + ", LSL=" + lsl + ", USL=" + usl + ", Target=" + target + ")\\n");
    } else {
         echo("fit <- MASS::fitdistr(" + x + ", densfun = \\"" + dist + "\\")\\n");

         // Same scaling logic for preview
         echo("h <- hist(" + x + ", plot=FALSE)\\n");
         echo("d <- density(" + x + ")\\n");
         echo("y_max <- max(h$density, d$y) * 1.2\\n");

         echo("hist(" + x + ", freq=FALSE, ylim=c(0, y_max), main=\\"Capability Histogram (" + dist + ")\\")\\n");
         echo("curve(do.call(\\"d" + dist + "\\", c(list(x), as.list(fit$estimate))), add=TRUE, col=\\"red\\", lwd=2)\\n");
         echo("if(!is.na(" + lsl + ")) abline(v=" + lsl + ", col=\\"red\\", lty=3, lwd=2)\\n");
         echo("if(!is.na(" + usl + ")) abline(v=" + usl + ", col=\\"red\\", lty=3, lwd=2)\\n");
    }
  ')

  component_cap <- rk.plugin.component(
    "Process Capability",
    xml = list(dialog = dialog_cap),
    js = list(require="SixSigma, MASS", calculate=js_calc_cap, printout=js_print_cap, preview=js_preview_cap),
    hierarchy = common_hierarchy,
    rkh = list(help = help_cap)
  )

  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_rr),
    js = list(require="SixSigma", calculate=js_calc_rr, printout=js_print_rr, preview=js_preview_rr),
    rkh = list(help = help_rr),
    components = list(
        component_attr,
        component_cap
    ),
    pluginmap = list(
        name = "Gage R and R",
        hierarchy = common_hierarchy
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.six.sigma' generated successfully.\n")
  cat("To complete installation:\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})
