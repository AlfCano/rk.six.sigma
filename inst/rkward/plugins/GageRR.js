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
    
    args += ", main = \"Gage R&R Study\"";
  
    echo("require(SixSigma)\n");
    echo("rr_prev <- SixSigma::ss.rr(" + args + ", print_plot = TRUE)\n");
  
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(SixSigma)){stop(" + i18n("Preview not available, because package SixSigma is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(SixSigma)\n");
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
    
    args += ", main = \"Gage R&R Study\"";
  
    echo("rr_result <- SixSigma::ss.rr(" + args + ", print_plot = FALSE)\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("GageRR results")).print();	
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
    
    args += ", main = \"Gage R&R Study\"";
  
    echo("require(SixSigma)\n");
    echo("rk.header(\"Gage R&R (Crossed) Results\", level=3);\n");
    echo("print(rr_result)\n");
    
    if (plot == "1") {
        echo("rk.graph.on()\n");
        echo("plot(rr_result)\n");
        echo("rk.graph.off()\n");
    }
  

}

