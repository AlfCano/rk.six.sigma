// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(irr)\n");
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
  
    var df = getValue("attr_data");
    var s_col = getColName(getValue("attr_sample"));
    var a_col = getColName(getValue("attr_appr"));
    var r_col = getColName(getValue("attr_rating"));
  
    echo("# Reshape data to Matrix (Subjects x Raters)\n");
    echo("attr_wide <- reshape(data = " + df + "[, c(\"" + s_col + "\", \"" + a_col + "\", \"" + r_col + "\")], \n");
    echo("                     idvar = \"" + s_col + "\", timevar = \"" + a_col + "\", direction = \"wide\")\n");
    echo("rownames(attr_wide) <- attr_wide[[1]]\n");
    echo("attr_wide <- attr_wide[, -1] # Remove ID column\n");
    echo("attr_matrix <- as.matrix(attr_wide)\n");
    
    echo("attr_agreement_res <- irr::kappam.fleiss(attr_matrix)\n");
  
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Attribute Agreement results")).print();

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
  
    var df = getValue("attr_data");
    var s_col = getColName(getValue("attr_sample"));
    var a_col = getColName(getValue("attr_appr"));
    var r_col = getColName(getValue("attr_rating"));
  
    var save_name = getValue("attr_save.objectname");

    echo("require(irr)\n");
    echo("rk.header(\"Attribute Agreement Analysis (Fleiss Kappa)\", level=3);\n");
    echo("rk.print(\"Data reshaped from: " + df + "\")\n");
    
    echo("irr_summary <- data.frame(Subjects = attr_agreement_res$subjects, Raters = attr_agreement_res$raters, Kappa = round(attr_agreement_res$value, 3), z = round(attr_agreement_res$statistic, 3), p.value = attr_agreement_res$p.value)\n");
    echo("rk.results(irr_summary)\n");
    
    echo("rk.print(paste(\"Interpretation: < 0.40 Poor, 0.40-0.75 Fair/Good, > 0.75 Excellent\"))\n");
    
    if (save_name != "") {
        echo("assign(\"" + save_name + "\", attr_agreement_res, envir = .GlobalEnv)\n");
    }
  
	//// save result object
	// read in saveobject variables
	var attrSave = getValue("attr_save");
	var attrSaveActive = getValue("attr_save.active");
	var attrSaveParent = getValue("attr_save.parent");
	// assign object to chosen environment
	if(attrSaveActive) {
		echo(".GlobalEnv$" + attrSave + " <- attr_agreement_res\n");
	}

}

