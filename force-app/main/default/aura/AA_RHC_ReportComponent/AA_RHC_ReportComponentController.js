({
	doInit : function(component, event, helper){
		helper.getReports(component);
        helper.getAccounts(component);
        helper.getADOList(component);
        helper.getRVPList(component);
        },
    
    handleADOChange : function (component, event, helper){
        var selectedOptionsList = event.getParam("value");
        console.log(selectedOptionsList);
        component.set("v.selectedADO", selectedOptionsList);
    	},
    
    handleRVPChange : function (component, event, helper){
        var selectedOptionsList = event.getParam("value");
        console.log(selectedOptionsList);
        component.set("v.selectedRVP", selectedOptionsList);
    	},
    
    onReportChange : function(component, event, helper){
        var report = component.find("InputSelectReport").get("v.value");
        if(report === 'Contacts Reporting'){ 
            component.set("v.report1", true);
            component.set("v.report2", false);
        	component.set("v.report3", false);
            component.set("v.report4", false);
            component.set("v.showExtraFilters", false);
        	}
        else if(report === 'Activity Reporting'){
            component.set("v.report1", false);
            component.set("v.report2", true);
            component.set("v.report3", false);
            component.set("v.report4", false);
            component.set("v.showExtraFilters", false);
        	}
        else if(report === 'NPS Activity Report'){
            component.set("v.report1", false);
            component.set("v.report2", false);
            component.set("v.report3", false);
            component.set("v.report4", true);
            helper.getNPSActivities(component);
            component.set("v.showExtraFilters", true);
        	}
        else if(report === 'All Accounts Reporting'){
            component.set("v.report1", false);
            component.set("v.report2", false);
        	component.set("v.report3", true);
            component.set("v.report4", false);
            component.set("v.showExtraFilters", true);
            
            var startLetter = 'A';
            helper.getAllRHBRows(component, startLetter).then(
            $A.getCallback(function(result){
                
            })
        		)
            .then(
            $A.getCallback(function(result){
                var startLetter = 'B';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'C';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'D';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'E';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'F';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'G';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'H';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'I';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'J';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'K';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'L';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'M';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'N';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'O';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'P';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'Q';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'R';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'S';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'T';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'U';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'V';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'W';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )/*
            .then(
            $A.getCallback(function(result){
                var startLetter = 'X';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'Y';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'Z';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )*/
            .catch(
                    $A.getCallback(function(error){
                        // Something went wrong
                        alert('An error occurred : ' + error.message);
                    })
                );
            
        	}   
        helper.disableSelectAccount(component);
    	},
    
    runReport : function(component, event, helper){
        
        var report = component.find("InputSelectReport").get("v.value");
        
        if(report === 'Contacts Reporting'){ 
            helper.getFacility(component);
            helper.getDVPTeams(component);
        	helper.getRVPTeams(component);
        	helper.getADOTeams(component);
            helper.runReport(component);
            component.set("v.report1", true);
            component.set("v.report2", false);
        	component.set("v.report3", false);
        	component.set("v.report4", false);
        	}
        else if(report === 'Activity Reporting'){
            helper.getFacility(component);
            component.set("v.report1", false);
            component.set("v.report2", true);
            component.set("v.report3", false);
            component.set("v.report4", false);
        	helper.getDVPActivities(component);
            helper.getRVPActivities(component);
            helper.getADOActivities(component);
        	}
        else if(report === 'NPS Activity Report'){
            component.set("v.report1", false);
            component.set("v.report2", false);
            component.set("v.report3", false);
            component.set("v.report4", true);
            helper.getNPSActivities(component);
            component.set("v.showExtraFilters", true);
        	}
        else if(report === 'All Accounts Reporting'){
            component.set("v.report1", false);
            component.set("v.report2", false);
        	component.set("v.report3", true);
            component.set("v.report4", false);
            helper.getAllRHBActive(component);
        	
            var startLetter = 'A';
            helper.getAllRHBRows(component, startLetter).then(
            $A.getCallback(function(result){
                
            })
        		)
            .then(
            $A.getCallback(function(result){
                var startLetter = 'B';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'C';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'D';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'E';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'F';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'G';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'H';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'I';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'J';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'K';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'L';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'M';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'N';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'O';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'P';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'Q';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'R';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'S';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'T';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'U';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'V';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'W';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )/*
            .then(
            $A.getCallback(function(result){
                var startLetter = 'X';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'Y';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )
            .then(
            $A.getCallback(function(result){
                var startLetter = 'Z';
                return helper.getAllRHBRows(component, startLetter);      
            })
            )*/
            .catch(
                    $A.getCallback(function(error){
                        // Something went wrong
                        alert('An error occurred : ' + error.message);
                    })
                );
        
        	}
        },
    
    next : function(component, event, helper){
     	helper.next(component, event, helper);
 		},
    previous : function(component, event, helper){
     	helper.previous(component, event, helper);
 		},
    
    sortName: function(component, event, helper) {
        helper.sortByContact(component, "Name");
    	},
    
    sortTitle : function(component, event, helper){
        helper.sortByContact(component, "Title");
    	},
    
    sortAddress : function(component, event, helper){
        helper.sortByContact(component, "MailingStreet");
    	},
    
    sortCity : function(component, event, helper){
        helper.sortByContact(component, "MailingCity");
    	},
    
    sortState : function(component, event, helper){
        helper.sortByContact(component, "MailingState");
    	},
    
    sortZip : function(component, event, helper){
        helper.sortByContact(component, "MailingPostalCode");
    	},
    
    sortPhone : function(component, event, helper){
        helper.sortByContact(component, "Phone");
    	},
    
    sortDVPName: function(component, event, helper) {
        helper.sortByDVP(component, "Owner.Name");
    	},
    
    sortDVPType : function(component, event, helper){
        helper.sortByDVP(component, "Type");
    	},
    
    sortDVPDate : function(component, event, helper){
        helper.sortByDVP(component, "StartDateTime");
    	},
    
    sortDVPDescription : function(component, event, helper){
        helper.sortByDVP(component, "Description");
    	},
    
    sortRVPName: function(component, event, helper) {
        helper.sortByRVP(component, "Owner.Name");
    	},
    
    sortRVPType : function(component, event, helper){
        helper.sortByRVP(component, "Type");
    	},
    
    sortRVPDate : function(component, event, helper){
        helper.sortByRVP(component, "StartDateTime");
    	},
    
    sortRVPDescription : function(component, event, helper){
        helper.sortByRVP(component, "Description");
    	},
    
    sortADOName: function(component, event, helper) {
        helper.sortByADO(component, "Owner.Name");
    	},
    
    sortADOType : function(component, event, helper){
        helper.sortByADO(component, "Type");
    	},
    
    sortADODate : function(component, event, helper){
        helper.sortByADO(component, "StartDateTime");
    	},
    
    sortADODescription : function(component, event, helper){
        helper.sortByADO(component, "Description");
    	},
    
    onTabChangeA : function(component, event, helper){
        component.set("v.letterStart", "a");
        component.set("v.letterEnd", "b");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeB : function(component, event, helper){
        component.set("v.letterStart", "b");
        component.set("v.letterEnd", "c");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeC : function(component, event, helper){
        component.set("v.letterStart", "c");
        component.set("v.letterEnd", "d");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeD : function(component, event, helper){
        component.set("v.letterStart", "d");
        component.set("v.letterEnd", "e");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeE : function(component, event, helper){
        component.set("v.letterStart", "e");
        component.set("v.letterEnd", "f");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeF : function(component, event, helper){
        component.set("v.letterStart", "f");
        component.set("v.letterEnd", "g");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeG : function(component, event, helper){
        component.set("v.letterStart", "g");
        component.set("v.letterEnd", "h");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeH : function(component, event, helper){
        component.set("v.letterStart", "h");
        component.set("v.letterEnd", "i");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeI : function(component, event, helper){
        component.set("v.letterStart", "i");
        component.set("v.letterEnd", "j");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeJ : function(component, event, helper){
        component.set("v.letterStart", "j");
        component.set("v.letterEnd", "k");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeK : function(component, event, helper){
        component.set("v.letterStart", "k");
        component.set("v.letterEnd", "l");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeL : function(component, event, helper){
        component.set("v.letterStart", "l");
        component.set("v.letterEnd", "m");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeM : function(component, event, helper){
        component.set("v.letterStart", "m");
        component.set("v.letterEnd", "n");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeN : function(component, event, helper){
        component.set("v.letterStart", "n");
        component.set("v.letterEnd", "o");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeO : function(component, event, helper){
        component.set("v.letterStart", "o");
        component.set("v.letterEnd", "p");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeP : function(component, event, helper){
        component.set("v.letterStart", "p");
        component.set("v.letterEnd", "q");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeQ : function(component, event, helper){
        component.set("v.letterStart", "q");
        component.set("v.letterEnd", "r");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeR : function(component, event, helper){
        component.set("v.letterStart", "r");
        component.set("v.letterEnd", "s");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeS : function(component, event, helper){
        component.set("v.letterStart", "s");
        component.set("v.letterEnd", "t");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeT : function(component, event, helper){
        component.set("v.letterStart", "t");
        component.set("v.letterEnd", "u");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeU : function(component, event, helper){
        component.set("v.letterStart", "u");
        component.set("v.letterEnd", "v");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeV : function(component, event, helper){
        component.set("v.letterStart", "v");
        component.set("v.letterEnd", "w");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeW : function(component, event, helper){
        component.set("v.letterStart", "w");
        component.set("v.letterEnd", "x");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeX : function(component, event, helper){
        component.set("v.letterStart", "x");
        component.set("v.letterEnd", "y");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeY : function(component, event, helper){
        component.set("v.letterStart", "y");
        component.set("v.letterEnd", "z");
        helper.getAllRHBActive(component);            
    	},
    
    onTabChangeZ : function(component, event, helper){
        component.set("v.letterStart", "z");
        component.set("v.letterEnd", "zz");
        helper.getAllRHBActive(component);            
    	},
    
    downloadCsvAllAccount : function(component,event,helper){
        var ado = component.get("v.selectedADO", "v.value");
        var rvp = component.get("v.selectedRVP", "v.value");
        
        console.log("ado length: " + ado);
        console.log("rvp length: " + rvp);
        
        
            var stockData = [];
            var ready = component.get("v.processingFinished");
            if(ready === true){
            var a = component.get("v.aList");
            var b = component.get("v.bList");
            var c = component.get("v.cList");
            var d = component.get("v.dList");
            var e = component.get("v.eList");
            var f = component.get("v.fList");
            var g = component.get("v.gList");
            var h = component.get("v.hList");
            var i = component.get("v.iList");
            var j = component.get("v.jList");
            var k = component.get("v.kList");
            var l = component.get("v.lList");
            var m = component.get("v.mList");
            var n = component.get("v.nList");
            var o = component.get("v.oList");
            var p = component.get("v.pList");
            var q = component.get("v.qList");
            var r = component.get("v.rList");
            var s = component.get("v.sList");
            var t = component.get("v.tList");
            var u = component.get("v.uList");
            var v = component.get("v.vList");
            var w = component.get("v.wList");
            var x = component.get("v.xList");
            var y = component.get("v.yList");
            var z = component.get("v.zList");
            
            for(var aa=0; aa< a.length; aa++){
                 	stockData.push(a[aa]);    
    				}
            for(var bb=0; bb< b.length; bb++){
                 	stockData.push(b[bb]);    
    				}
                for(var cc=0; cc< c.length; cc++){
                 	stockData.push(c[cc]);    
    				}
                for(var dd=0; dd< d.length; dd++){
                 	stockData.push(d[dd]);    
    				}
                for(var ee=0; ee< e.length; ee++){
                 	stockData.push(e[ee]);    
    				}
                for(var ff=0; ff< f.length; ff++){
                 	stockData.push(f[ff]);    
    				}
                for(var gg=0; gg< g.length; gg++){
                 	stockData.push(g[gg]);    
    				}
                for(var hh=0; hh< h.length; hh++){
                 	stockData.push(h[hh]);    
    				}
                for(var ii=0; ii< i.length; ii++){
                 	stockData.push(i[ii]);    
    				}
                for(var jj=0; jj< j.length; jj++){
                 	stockData.push(j[jj]);    
    				}
                for(var kk=0; kk< k.length; kk++){
                 	stockData.push(k[kk]);    
    				}
                for(var ll=0; ll< l.length; ll++){
                 	stockData.push(l[ll]);    
    				}
                for(var mm=0; mm< m.length; mm++){
                 	stockData.push(m[mm]);    
    				}
                for(var nn=0; nn< n.length; nn++){
                 	stockData.push(n[nn]);    
    				}
                for(var oo=0; oo< o.length; oo++){
                 	stockData.push(o[oo]);    
    				}
                for(var pp=0; pp< p.length; pp++){
                 	stockData.push(p[pp]);    
    				}
                for(var qq=0; qq< q.length; qq++){
                 	stockData.push(q[qq]);    
    				}
                for(var rr=0; rr< r.length; rr++){
                 	stockData.push(r[rr]);    
    				}
                for(var ss=0; ss< s.length; ss++){
                 	stockData.push(s[ss]);    
    				}
                for(var tt=0; tt< t.length; tt++){
                 	stockData.push(t[tt]);    
    				}
                for(var uu=0; uu< u.length; uu++){
                 	stockData.push(u[uu]);    
    				}
                for(var vv=0; vv< v.length; vv++){
                 	stockData.push(v[vv]);    
    				}
                for(var ww=0; ww< w.length; ww++){
                 	stockData.push(w[ww]);    
    				}
                for(var xx=0; xx< x.length; xx++){
                 	stockData.push(x[xx]);    
    				}
                for(var yy=0; yy< y.length; yy++){
                 	stockData.push(y[yy]);    
    				}
                for(var zz=0; zz< z.length; zz++){
                 	stockData.push(z[zz]);    
    				}
            
        	var csv = helper.convertArrayOfObjectsToCSVAllAccount(component,stockData);   
        	if(csv == null){
            	return;
        		}
        	else{
                if(navigator.msSaveBlob){ // IE 10+ 
				   navigator.msSaveBlob(new Blob([csv], { type: 'text/csv;charset=utf-8;' }), "AccountTeamData.csv"); 
                   }
                else{
        			var hiddenElement = document.createElement('a');
          			hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
         			hiddenElement.target = '_self'; // 
          			hiddenElement.download = 'AccountTeamData.csv';
          			document.body.appendChild(hiddenElement);
    	  			hiddenElement.click();
                	}
        		}
            }
            else{
            	alert("Data Compliation of the report is not yet complete.  Please wait a few moments and then try your request again.");
        		}
        },
    
    downloadCsvAllAccount2 : function(component,event,helper){
            var stockData = component.get("v.NPSActivityList");
            var csv = helper.convertArrayOfObjectsToCSVNPS(component,stockData);   
        	if(csv == null){
            	return;
        		}
        	else{
                if(navigator.msSaveBlob){ // IE 10+ 
				   navigator.msSaveBlob(new Blob([csv], { type: 'text/csv;charset=utf-8;' }), "AccountTeamData.csv"); 
                   }
                else{
        			var hiddenElement = document.createElement('a');
          			hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
         			hiddenElement.target = '_self'; // 
          			hiddenElement.download = 'AccountTeamData.csv';
          			document.body.appendChild(hiddenElement);
    	  			hiddenElement.click();
                	}
        		}
        },
    
})