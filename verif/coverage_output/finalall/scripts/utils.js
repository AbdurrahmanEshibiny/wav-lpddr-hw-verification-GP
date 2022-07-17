/*
 * This class is used to pares the URL
 * */
function UrlParserClass() {
	this.urlArgs = {};
	
	var qs = location.search.substring(1, location.search.length);
	var args = qs.split('&');
	var pair;
	
	for (var i=0 ; i<args.length ; i++) {
		pair = args[i].split('=');
		this.urlArgs[pair[0]] = pair[1];
	}
}

UrlParserClass.prototype.getFileNum = function() {
	return this.urlArgs.f;
};
UrlParserClass.prototype.getScopeId = function() {
	return this.urlArgs.s;
};

///////////////////////////////////////////////////////////////////////////////

function utils_getPageHeaderH1(coverageTypeString) {
	var h1 = document.createElement('H1');
	h1.innerHTML = g_oCONST.prod + ' ' + coverageTypeString + ' Coverage Report';
	return h1;
}
function utils_getButtonsTable() {
	var btable = document.createElement("table");
	btable.cellSpacing = "2";
	btable.cellPadding = "2";
	btable.className = "buttons";
	var row = document.createElement("tr");
	var td1 = document.createElement("td");
	var td2 = document.createElement("td");
	var td3 = document.createElement("td");
	td1.id = "showAll";
	td1.width = "100";
	td1.setAttribute("onclick", "showAll()");
	td1.className = "button_on";
	td1.title = "Display all coverage scopes and bins.";
	td1.innerHTML = "Show All";
	row.appendChild(td1);
	
	td2.id = "showCov";
	td2.width = "100";
	td2.setAttribute("onclick", "showCov()");
	td2.className = "button_off";
	td2.title = "Display only covered scopes and bins.";
	td2.innerHTML = "Show Covered";
	row.appendChild(td2);
	
	td3.id = "showMis";
	td3.width = "100";
	td3.setAttribute("onclick", "showMis()");
	td3.className = "button_off";
	td3.title = "Display only uncovered scopes and bins.";
	td3.innerHTML = "Show Missing";
	row.appendChild(td3);
	
	btable.appendChild(row);

	return btable;
}
