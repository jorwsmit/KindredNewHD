({	
    populateItem : function(component){
        var action = component.get("c.getMEDPARData");
        var id = component.get("v.recordId");
        console.log('ID: ' + id);
        action.setParams({
            "id" : component.get("v.recordId")
        	});                	
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('Populate',state);
            if(component.isValid() && state === "SUCCESS"){
                var stringItem = response.getReturnValue();
                component.set("v.mData", stringItem);
                component.set("v.medID", component.get("v.mData.Id"));
            	}            	
            else if(state === "ERROR"){
                console.log("===>>>=== ", response.getError());
            	}        	
        	});
        $A.enqueueAction(action);
	    },
    
})