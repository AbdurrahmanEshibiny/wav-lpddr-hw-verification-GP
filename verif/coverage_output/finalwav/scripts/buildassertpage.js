var g_cellClass = [ "odd", "even" ];
var g_cellClassRight = [ "odd_r", "even_r" ];
var g_cellClassRGrey = [ "odd_rGrey", "even_rGrey" ];
var g_a_divId;
var testHitDataScopeId;
var processAssertionsData;
var processConsData;
var hdlPaths = {};
var assertViewData = [];
var assertViewFileToRead = 0;
var MAX_NAME_LENGTH_HALF = 30;
var MAX_NAME_LENGTH = 80;
var TABLE_REASONABLE_LENGTH = 100;
var TABLE_LENGTH_MENUE = [[25, 50, 100, -1], [10, 25, 50, 100, "All"]];
// ///////////////////////////////////////////////////////////////////////////////////
/* creats cell and add it to row. */
function a_createCell(row, type, classt, span, txt, lnk, relAttribute,
		filterLabel, c_align, tooltip) {
	var newCell = document.createElement(type);
	newCell.className = classt;
	if (span > 1) {
		newCell.colSpan = span;
	}
	if (c_align) {
		newCell.align = c_align;
	}
	if (lnk) {
		var newElement = document.createElement('a');
		newElement.setAttribute("href", lnk);
		if (relAttribute) {
			newElement.setAttribute("rel", relAttribute);
		}
		newElement.innerHTML = txt;
		newCell.appendChild(newElement);
	} else {
		newCell.innerHTML = txt;
	}
	if (filterLabel) {
		newCell.innerHTML = newCell.innerHTML + '&nbsp;';
		var newElement = document.createElement('font');
		newElement.color = "#006699";
		newElement.innerHTML = "(Filtering Active)";
		newCell.appendChild(newElement);
	}
	if (tooltip) {
		newCell.setAttribute("title", tooltip);
	}
	row.appendChild(newCell);
	return;
};

function createAssertCell(row, tableCellType, countType, bin_num, isexcluded,
		lastRowIsOdd, data) {
	var exComment = lnktxt = celltxt = relAtt = tmp = celltxt = classtype = 0;
	if (countType) {
		tmp = data.countType;
	}
	if (tmp) {
		switch (tmp) {
		case 'Gr':
			classtype = 'bgGreen_r';
			break;
		case 'Rr':
			classtype = 'bgRed_r';
			break;
		case 'er':
			classtype = g_cellClassRight[lastRowIsOdd];
			break;
		case 'or':
			classtype = g_cellClassRight[lastRowIsOdd];
			break;
		default:
			classtype = '';
			break;
		}
	} else {
		classtype = g_cellClassRight[lastRowIsOdd];
	}
	celltxt = data['h' + bin_num];
	if (celltxt) {
		var hrefLnk = data['t' + bin_num];
		if (hrefLnk) {
			lnktxt = "pertest.htm?bin=a" + hrefLnk + "&scope="
					+ testHitDataScopeId;
			relAtt = 'popup 200 200';
		} else {
			lnktxt = 0;
			relAtt = 0;
		}
	} else {
		celltxt = '-';
	}
	if (isexcluded) {
		// if excluded override the class name
		classtype = g_cellClassRGrey[lastRowIsOdd];
		exComment = data['ec' + bin_num];
		if (exComment) {
			celltxt = celltxt + ' +';
		}
	}
	a_createCell(row, tableCellType, classtype, 0, celltxt, lnktxt, relAtt, 0,
			0, exComment);
};
// ///////////////////////////////////////////////////////////////////////////////////
function loadJsonFile(jsonFileName) {
	var headID = document.getElementsByTagName('head')[0];
	var jsonScript = document.createElement('script');
	jsonScript.type = 'text/javascript';
	jsonScript.src = jsonFileName;
	headID.appendChild(jsonScript);
}
function buildAssertionsTables(divId, filenum) {
	document.title = g_oCONST.prod + ' Coverage Report';
	urlArgsObj = new UrlParserClass();
	var divId = urlArgsObj.getScopeId();
	var filenum = urlArgsObj.getFileNum();
	processAssertionsData = function (data) {
		drawAssertTable(data);
	};
	g_a_divId = 'a' + divId;
	testHitDataScopeId = divId;
	loadJsonFile('a' + filenum + '.json');
}

function drawAssertTable(g_data) {
	var divObj = document.getElementById("content");
	var show_excl_button = 0;

	var table = 0;
	var buttonsTable = 0;
	var t = 0;
	
	if (g_data[g_a_divId].isPa) {
		document.body.insertBefore(
			utils_getPageHeaderH1(g_data[g_fsm_divId].isPa.title),
			divObj);
		var h4;
		h4 = document.createElement('h4');
		h4.innerHTML = 'UPF Object: ' + g_data[g_fsm_divId].isPa.objType;
		document.body.insertBefore(h4, divObj);
	} else {
		document.body.insertBefore(
			utils_getPageHeaderH1("Assertion"),
			divObj);
	}
	
	buttonsTable = utils_getButtonsTable();
	divObj.appendChild(buttonsTable);

	table = document.createElement('table');
	table.cellSpacing = "2";
	table.cellPadding = "2";

	var newRow = document.createElement('tr');

	a_createCell(newRow, "TH", 'even', 0, 'Assertions', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Failure Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Pass Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Attempt Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Vacuous Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Disable Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Active Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Peak Active Count', 0, 0, 0, 0, 0);
	a_createCell(newRow, "TH", 'even', 0, 'Status', 0, 0, 0, 0, 0);

	table.appendChild(newRow);
	var lastRowOdd = 0;
	var dataArr = g_data[g_a_divId].assertions;
	for (var r = 1; r < dataArr.length; r++) {
		newRow = document.createElement('tr');
		var tmp = 0;
		var excluded = 0;
		var lnktxt = 0;
		var celltxt = 0;
		var relAtt = 0;

		// row class if existing
		tmp = dataArr[r].cr;
		switch (tmp) {
		case 'c':
			newRow.className = 'covered';
			break;
		case 'm':
			newRow.className = 'missing';
			break;
		case 'e':
			newRow.className = 'excluded';
			excluded = 1;
			show_excl_button = 1;
			break;
		default:
			newRow.className = '';
			break;
		}

		classtype = g_cellClass[lastRowOdd];
		lnktxt = dataArr[r].lnk;

		tmp = dataArr[r].z;
		if (tmp) {
			celltxt = tmp.replace(">", "&gt;").replace("<", "&lt;");
		}
		a_createCell(newRow, "TD", classtype, 0, celltxt, lnktxt, 0, 0, 0, 0);
		
		createAssertCell(newRow, "TD", 'fc', 0, excluded, lastRowOdd, dataArr[r]);
		createAssertCell(newRow, "TD", 'pc', 1, excluded, lastRowOdd, dataArr[r]);
		createAssertCell(newRow, "TD", 0, 2, excluded, lastRowOdd, dataArr[r]);
		createAssertCell(newRow, "TD", 0, 3, excluded, lastRowOdd, dataArr[r]);
		createAssertCell(newRow, "TD", 0, 4, excluded, lastRowOdd, dataArr[r]);
		createAssertCell(newRow, "TD", 0, 5, excluded, lastRowOdd, dataArr[r]);
		createAssertCell(newRow, "TD", 0, 6, excluded, lastRowOdd, dataArr[r]);

		if (excluded == 0) {
			tmp = dataArr[r].c;
			switch (tmp) {
			case 'F':
				classtype = 'red';
				celltxt = "Failed";
				break;
			case 'Z':
				classtype = 'red';
				celltxt = "ZERO";
				break;
			case 'g':
				classtype = 'green';
				celltxt = "Covered";
				break;
			default:
				classtype = '';
				celltxt = 0;
				break;
			}
		} else {
			classtype = 'grey';
			celltxt = "Excluded";
		}
		a_createCell(newRow, "TD", classtype, 0, celltxt, 0, 0, 0, 0, 0);

		lastRowOdd = lastRowOdd ? 0 : 1;
		table.appendChild(newRow);
	}

	if (show_excl_button == 1) {
		if (buttonsTable) {
			var newCell = document.createElement('TD');
			newCell.id = "showExcl";
			newCell.width = 106;
			newCell.setAttribute("onclick", "showExcl()");
			newCell.className = "button_off";
			newCell.title = "Display only excluded scopes and bins.";
			newCell.innerHTML = "Show Excluded";
			buttonsTable.rows[0].appendChild(newCell);
		}
	}
	divObj.appendChild(document.createElement("hr"));
	divObj.appendChild(table);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function getAssertViewTableConfigObj(assertData) {
	var hitCols = [
					'Attempt Count',
					'Vacuous Count',
					'Disable Count',
					'Active Count',
					'Peak Active Count'
	];
	var configObj = {
		paging : false,
		info   : false,
		data   : assertData,
		order  : [[0, 'asc' ]], // initially order the table according to 1st column (name)
		createdRow: function (rowDomObj, rowData, rowDataIdx) {
			if (rowData.cr == 'e') {
				$(rowDomObj).addClass('grayFont');
			}
		},
		columns:
			[
			{
				title    : 'Assertions',
				className: 'dt-left nowrap',
				data     : null,
				render   : {
					filter : function (cellData, type, fullRowJsonObj, meta) {
						var content = hdlPaths[cellData.parent] + '/' + cellData.z;
						switch (cellData.c) {
							case 'F':
								content +=  '#status:Failed';
							break;
							case 'Z':
								content += '#status:ZERO';
							break;
							case 'g':
								content += '#status:Covered';
							break;
							default:
							break;
						}
						return content;
					},
					display: function (cellData, type, fullRowJsonObj, meta) {
						var parent = hdlPaths[cellData.parent].path;
						var fileNum = hdlPaths[cellData.parent].fileNum;
						var content = '<a href="a.htm?f=' + fileNum + '&s=' + cellData.parent + '">';
						if (parent.length > MAX_NAME_LENGTH) {
							content += parent.slice(0, MAX_NAME_LENGTH_HALF)
									+ '....'
									+ parent.slice((parent.length - MAX_NAME_LENGTH_HALF),(parent.length - 1));
						} else {
							content += parent;
						}
						content += '/' + cellData.z;
						return content;
					}
				}
			},
			{
				title     : 'Failure Count',
				searchable: false,
				className : 'dt-right',
				data      : 'h0',
				defaultContent: '-',
				createdCell: function (cellDomObj, cellData, rowData, rowIdx, collIdx) {
					$(cellDomObj).addClass(rowData.fc);
				}
			},
			{
				title     : 'Pass Count',
				searchable: false,
				className : 'dt-right',
				data      : 'h1',
				defaultContent: '-',
				createdCell: function (cellDomObj, cellData, rowData, rowIdx, collIdx) {
					$(cellDomObj).addClass(rowData.pc);
				}
			}
			]
	};
	if (g_assertDebug) {
		for (indx = 0; indx < hitCols.length; ++indx) {
			var dataIndx = 'h' + (indx + 2);
			configObj.columns.push(
				{
					title     : hitCols[indx],
					searchable: false,
					className : 'dt-right',
					data      : dataIndx,
					defaultContent: '-'
				}
			)
		}
	}
	
	configObj.columns.push(
		{
			title     : 'Status',
			searchable: false,
			className : 'dt-right',
			data      : null,
			render: {
				display: function (cellData, type, fullRowJsonObj, meta) {
					switch (cellData.c) {
						case 'F':
							return 'Failed';
						break;
						case 'Z':
							return 'ZERO';
						break;
						case 'g':
							return 'Covered';
						break;
						default:
							return '';
						break;
					}
				}
			},
			createdCell: function (cellDomObj, cellData, rowData, rowIdx, collIdx) {
				switch (cellData.c) {
					case 'F':
						$(cellDomObj).addClass('red');
					break;
					case 'Z':
						$(cellDomObj).addClass('red');
					break;
					case 'g':
						$(cellDomObj).addClass('green');
					break;
					default:
					break;
				}
			}
		}
	);
	
	if (assertData.length > TABLE_REASONABLE_LENGTH) {
		configObj.paging = true;
		configObj.info   = true;
		configObj.deferRender = true;
		configObj.lengthMenu = TABLE_LENGTH_MENUE;
	}
	
	return configObj;
}

function drawAssertViewTable() {
	var body = document.getElementsByTagName('body')[0];
	var assertTable = document.createElement('table');
	var config = getAssertViewTableConfigObj(assertViewData);
	assertTable.className = 'tableTheme stripe';
	body.appendChild(assertTable);
	$(assertTable).DataTable(config);
}

function genDataAssertView(data, jsonData) {
	var fileNum = jsonData[0];
	for (scopeIdx=1;scopeIdx<jsonData.length; ++scopeIdx) {
		var scopeHash = jsonData[scopeIdx][0];
		var scopeName = jsonData[scopeIdx][1];
		var newAsserts = data['a'+ scopeHash]['assertions'];
		hdlPaths[scopeHash] = {
			path: scopeName,
			fileNum: fileNum
		};
		for(cvgIdx=1;cvgIdx < newAsserts.length; ++cvgIdx) {
			newAsserts[cvgIdx].parent = scopeHash;
			assertViewData.push(newAsserts[cvgIdx]);
		}
	}
	assertViewFileToRead--;
	if (assertViewFileToRead == 0) {
		drawAssertViewTable();
	}
}

function processAssertConsData(asserts) {
	var jsonData;
	assertViewFileToRead = asserts.length;
	processAssertionsData = function(data) {
		genDataAssertView(data, jsonData);
	};
	for (i=0; i < asserts.length; ++i) {
		jsonData = asserts[i];
		loadJsonFile('a' + jsonData[0] + '.json');
	}
}

function buildAssertViewTable() {
	processConsData = function(asserts) {
		return processAssertConsData(asserts);
	}
	loadJsonFile('assertCons.js');
}
