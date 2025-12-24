// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
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
            return inner.replace(']]', '').replace(/["']/g, '');
        }
        return fullPath;
    }
  
    var x = getValue("cap_var");
    var lsl = getValue("cap_lsl");
    var usl = getValue("cap_usl");
    var target = getValue("cap_target");
    var dist = getValue("cap_dist");
    
    if (lsl == "") lsl = "NA";
    if (usl == "") usl = "NA";
    if (target == "") target = "NA";
  
    if (dist == "norm") {
         echo("SixSigma::ss.study.ca(" + x + ", LSL=" + lsl + ", USL=" + usl + ", Target=" + target + ")\n");
    } else {
         echo("fit <- MASS::fitdistr(" + x + ", densfun = \"" + dist + "\")\n");
         
         // Same scaling logic for preview
         echo("h <- hist(" + x + ", plot=FALSE)\n");
         echo("d <- density(" + x + ")\n");
         echo("y_max <- max(h$density, d$y) * 1.2\n");
         
         echo("hist(" + x + ", freq=FALSE, ylim=c(0, y_max), main=\"Capability Histogram (" + dist + ")\")\n");
         echo("curve(do.call(\"d" + dist + "\", c(list(x), as.list(fit$estimate))), add=TRUE, col=\"red\", lwd=2)\n");
         echo("if(!is.na(" + lsl + ")) abline(v=" + lsl + ", col=\"red\", lty=3, lwd=2)\n");
         echo("if(!is.na(" + usl + ")) abline(v=" + usl + ", col=\"red\", lty=3, lwd=2)\n");
    }
  
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(SixSigma, MASS)){stop(" + i18n("Preview not available, because package SixSigma, MASS is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(SixSigma, MASS)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

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
            return inner.replace(']]', '').replace(/["']/g, '');
        }
        return fullPath;
    }
  
    var x = getValue("cap_var");
    var lsl = getValue("cap_lsl");
    var usl = getValue("cap_usl");
    var target = getValue("cap_target");
    var dist = getValue("cap_dist");
    
    if (lsl == "") lsl = "NA";
    if (usl == "") usl = "NA";
    if (target == "") target = "NA";
  
    if (dist == "norm") {
        echo("capability_res <- SixSigma::ss.study.ca(" + x + ", LSL=" + lsl + ", USL=" + usl + ", Target=" + target + ")\n");
    } else {
        echo("# Fit Distribution: " + dist + "\n");
        echo("fit <- MASS::fitdistr(" + x + ", densfun = \"" + dist + "\")\n");
        
        echo("q_lower <- do.call(\"q" + dist + "\", c(list(p=0.00135), as.list(fit$estimate)))\n");
        echo("q_upper <- do.call(\"q" + dist + "\", c(list(p=0.99865), as.list(fit$estimate)))\n");
        echo("q_med   <- do.call(\"q" + dist + "\", c(list(p=0.5), as.list(fit$estimate)))\n");
        
        echo("lsl <- " + lsl + "\n");
        echo("usl <- " + usl + "\n");
        echo("pp <- (q_upper - q_lower) / 6\n");
        echo("ppk_l <- if(!is.na(lsl)) (q_med - lsl) / (q_med - q_lower) else NA\n");
        echo("ppk_u <- if(!is.na(usl)) (usl - q_med) / (q_upper - q_med) else NA\n");
        echo("ppk <- min(ppk_l, ppk_u, na.rm=TRUE)\n");
        
        echo("capability_res <- fit\n");
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Process Capability results")).print();	
	}
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
            return inner.replace(']]', '').replace(/["']/g, '');
        }
        return fullPath;
    }
  
    var x = getValue("cap_var");
    var lsl = getValue("cap_lsl");
    var usl = getValue("cap_usl");
    var target = getValue("cap_target");
    var dist = getValue("cap_dist");
    
    if (lsl == "") lsl = "NA";
    if (usl == "") usl = "NA";
    if (target == "") target = "NA";
  
    var save_name = getValue("cap_save.objectname");

    echo("rk.header(\"Process Capability Analysis (" + dist + ")\", level=3);\n");
    
    if (dist == "norm") {
        echo("print(capability_res)\n");
        echo("rk.graph.on()\n");
        echo("plot(capability_res)\n");
        echo("rk.graph.off()\n");
    } else {
        echo("rk.header(\"Distribution Parameters\", level=4);\n");
        echo("rk.results(as.data.frame(t(capability_res$estimate)))\n");
        
        echo("rk.header(\"Capability Indices (Quantile Method)\", level=4);\n");
        echo("res_tab <- data.frame(Index = c(\"Pp (Overall)\", \"Ppk (Overall)\"), Value = round(c(pp, ppk), 3))\n");
        echo("rk.results(res_tab)\n");
        
        echo("rk.graph.on()\n");
        // NEW: Calculate max height for Y-axis scaling
        echo("h <- hist(" + x + ", plot=FALSE)\n");
        echo("d <- density(" + x + ")\n");
        echo("y_max <- max(h$density, d$y) * 1.2\n");
        
        // Plot with custom ylim
        echo("hist(" + x + ", freq=FALSE, ylim=c(0, y_max), main=\"Capability Histogram (" + dist + ")\")\n");
        echo("lines(density(" + x + "), lty=2)\n");
        echo("curve(do.call(\"d" + dist + "\", c(list(x), as.list(capability_res$estimate))), add=TRUE, col=\"red\", lwd=2)\n");
        echo("if(!is.na(" + lsl + ")) abline(v=" + lsl + ", col=\"red\", lty=3, lwd=2)\n");
        echo("if(!is.na(" + usl + ")) abline(v=" + usl + ", col=\"red\", lty=3, lwd=2)\n");
        echo("rk.graph.off()\n");
    }
    
    if (save_name != "") {
        echo("assign(\"" + save_name + "\", capability_res, envir = .GlobalEnv)\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var capSave = getValue("cap_save");
		var capSaveActive = getValue("cap_save.active");
		var capSaveParent = getValue("cap_save.parent");
		// assign object to chosen environment
		if(capSaveActive) {
			echo(".GlobalEnv$" + capSave + " <- capability_res\n");
		}	
	}

}

