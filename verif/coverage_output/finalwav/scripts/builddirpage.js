var g_cellClass = [ "odd", "even" ];
var g_cellClassRight = [ "odd_r", "even_r" ];
var g_d_divId;
var testHitDataScopeId;
var processDirectivesData;
var processConsData;
var hdlPaths = {};
var dirViewData = [];
var dirViewFileToRead = 0;
var MAX_NAME_LENGTH_HALF = 30;
var MAX_NAME_LENGTH = 80;
var TABLE_REASONABLE_LENGTH = 100;
var TABLE_LENGTH_MENUE = [[25, 50, 100, -1], [10, 25, 50, 100, "All"]];

function d_createCell(row, type, classt, span, txt, lnk, relAttribute, c_align,
		styleColor, tooltip) {
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
	if (styleColor) {
		newCell.style.color = styleColor;
	}
	if (tooltip) {
		newCell.setAttribute("title", tooltip);
	}
	row.appendChild(newCell);
	return;
};

function loadJsonFile(filename) {
	var headID = document.getElementsByTagName('head')[0];
	var jsonScript = document.createElement('script');
	jsonScript.type = 'text/javascript';
	jsonScript.src = filename;
	headID.appendChild(jsonScript);
}

function buildDirTable() {
	document.title = g_oCONST.prod + ' Coverage Report';
	urlArgsObj = new UrlParserClass();
	var divId = urlArgsObj.getScopeId();
	var filenum = urlArgsObj.getFileNum();
	processDirectivesData = function (data) {
		drawAssertTable(data);
	};
	g_d_divId = 'd' + divId;
	testHitDataScopeId = divId;
	loadJsonFile('d' + filenum + '.json');
}

function drawAssertTable(g_data) {
	var divObj = document.getElementById("content");
	document.body.insertBefore(
		utils_getPageHeaderH1("Statement"),
		divObj);
		
	var buttonsTable = utils_getButtonsTable();
	document.body.insertBefore(
		buttonsTable,
		divObj);
	
	var show_excl_button = 0;
	var table = 0;
	var t = 0;

	table = document.createElement('table');

	table.cellSpacing = "2";
	table.cellPadding = "2";

	var newRow = document.createElement('tr');

	d_createCell(newRow, 'TH', 'even', 0, 'Cover Directive', 0, 0, 'left', 0, 0);
	d_createCell(newRow, 'TH', 'even', 0, 'Hits', 0, 0, 0, 0, 0);
	d_createCell(newRow, 'TH', 'even', 0, 'Status', 0, 0, 0, 0, 0);
	table.appendChild(newRow);
	var lastRowOdd = 0;
	var dataArr = g_data[g_d_divId];
	table.appendChild(newRow);
	// loop on the rest of the rows
	for (var r = 1; r < dataArr.length; r++) {
		var newRow = document.createElement('tr');
		var excluded = 0;
		var classtype = 0;
		var lnktxt = 0;
		var tmp = 0;
		var celltxt = 0;

		newRow = document.createElement('tr');

		// row class if existing
		tmp = dataArr[r].cr;
		switch (tmp) {
		case 'c':
			newRow.className = 'covered';
			break;
		case 'm':
			newRow.className = 'missing';
			break;
		case 'n':
			newRow.className = 'neutral';
			break;
		case 'e': // excluded
			excluded = 1;
			newRow.className = 'excluded';
			show_excl_button = 1;
			break;
		default:
			newRow.className = '';
			break;
		}

		lnktxt = dataArr[r].lnk;
		name = dataArr[r].z;
		if (name) {
			if (name.match(/^<.*>$/)) {
				celltxt = name.replace(">", "&gt;").replace("<", "&lt;");
			} else {
				celltxt = name;
			}
		}
		d_createCell(newRow, 'TD', g_cellClass[lastRowOdd], 0, celltxt, lnktxt,
				0, 0, 0, 0);

		tmp = dataArr[r].h;
		if (tmp) {
			var styleTxt = 0;
			var relAtt = 0;
			var alignTxt = 0;
			var exComment = 0;
			var hrefLnk = dataArr[r].k;
			if (hrefLnk) {
				lnktxt = "pertest.htm?bin=d" + hrefLnk + "&scope="
						+ testHitDataScopeId;
				relAtt = 'popup 200 200';
			} else {
				lnktxt = relAtt = 0;
			}
			celltxt = tmp;
			if (excluded) {
				exComment = dataArr[r].ec;
				if (exComment) {
					celltxt = celltxt + ' +';
				}
			}
			d_createCell(newRow, 'TD', g_cellClassRight[lastRowOdd], 0,
					celltxt, lnktxt, relAtt, 0, excluded ? "dimGrey" : 0,
					exComment);

			if (excluded == 0) {
				tmp = dataArr[r].c;
				switch (tmp) {
				case 'r':
					classtype = 'red';
					celltxt = "ZERO";
					break;
				case 'g':
					classtype = 'green';
					celltxt = "Covered";
					break;
				default:
					classtype = '';
					break;
				}
			} else {
				classtype = 'grey';
				celltxt = 'Excluded';
			}
			alignTxt = styleTxt = 0;
		} else {
			d_createCell(newRow, 'TD', g_cellClass[lastRowOdd], 0, "--", 0, 0,
					"center", excluded ? "dimGrey" : 0, 0);

			classtype = g_cellClass[lastRowOdd];
			alignTxt = "center";
			celltxt = "--";
			if (excluded) {
				styleTxt = "dimGrey";
			} else {
				styleTxt = 0;
			}
		}
		d_createCell(newRow, 'TD', classtype, 0, celltxt, 0, 0, alignTxt,
				styleTxt, 0);
		lastRowOdd = lastRowOdd ? 0 : 1;
		table.appendChild(newRow);
	}

	if (show_excl_button == 1) {
		if (buttonsTable.className.match('buttons')) {
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
	divObj.appendChild(document.createElement('hr'));
	divObj.appendChild(table);
}
function getDirViewTableConfigObj(dirData) {
	var configObj = {
		paging : false,
		info   : false,
		data   : dirData,
		order  : [[0, 'asc' ]], // initially order the table according to 1st column (name)
		createdRow: function (rowDomObj, rowData, rowDataIdx) {
			if (rowData.cr == 'e') {
				$(rowDomObj).addClass('grayFont');
			}
		},
		columns:
			[
			{
				title    : 'Cover Directives',
				className: 'dt-left nowrap',
				data     : null,
				render   : {
					filter : function (cellData, type, fullRowJsonObj, meta) {
						var content = hdlPaths[cellData.parent] + '/' + cellData.z;
						switch (cellData.c) {
							case 'r':
								content += '#status:Missed';
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
						var content = '<a href="d.htm?f=' + fileNum + '&s=' + cellData.parent + '">';
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
				title     : 'Hits',
				searchable: false,
				className : 'dt-right',
				data      : 'h',
				defaultContent: '-'
			},
			{
				title     : 'Status',
				searchable: false,
				orderable: false,
				className : 'dt-right',
				data      : null,
				render: {
					display: function (cellData, type, fullRowJsonObj, meta) {
						switch (cellData.c) {
							case 'r':
								return 'Missed';
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
						case 'r':
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
			]
	};
	
	if (dirData.length > TABLE_REASONABLE_LENGTH) {
		configObj.paging = true;
		configObj.info   = true;
		configObj.deferRender = true;
		configObj.lengthMenu = TABLE_LENGTH_MENUE;
	}
	
	return configObj;
}

function drawDirViewTable() {
	var body = document.getElementsByTagName('body')[0];
	var dirTable = document.createElement('table');
	var config = getDirViewTableConfigObj(dirViewData);
	dirTable.className = 'tableTheme stripe';
	body.appendChild(dirTable);
	$(dirTable).DataTable(config);
}

function genDataDirView(data, jsonData) {
	var fileNum = jsonData[0];
	for (scopeIdx=1;scopeIdx<jsonData.length; ++scopeIdx) {
		var scopeHash = jsonData[scopeIdx][0];
		var scopeName = jsonData[scopeIdx][1];
		var newDirs = data['d'+ scopeHash];
		hdlPaths[scopeHash] = {
			path: scopeName,
			fileNum: fileNum
		};
		for(dirIdx=1; dirIdx < newDirs.length; ++dirIdx) {
			newDirs[dirIdx].parent = scopeHash;
			dirViewData.push(newDirs[dirIdx]);
		}
	}
	dirViewFileToRead--;
	if (dirViewFileToRead == 0) {
		drawDirViewTable();
	}
}

function processDirViewData(dirs) {
	var jsonData;
	dirViewFileToRead = dirs.length;
	processDirectivesData = function(data) {
		return genDataDirView(data, jsonData);
	};
	for (i=0; i < dirs.length; ++i) {
		jsonData = dirs[i];
		loadJsonFile('d' + jsonData[0] + '.json');
	}
}
function buildDirViewTable() {
	processConsData = function (dirs) {
		return processDirViewData(dirs);
	}
	loadJsonFile('dirCons.js');
}
