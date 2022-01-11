public with sharing virtual class SetManagerB2C extends SetManagerBase {
    

    public SetManagerB2C(SetManagerModel model){
        super(model);
    }

    protected void setManagerCommon(List<User> managers){ 
        
        for(User manager : managers)
        {
            if(manager.UserRole.DeveloperName != currentOrderItem.SalesOffice__r.RoleNameManager__c || 
            String.isBlank(cancellationRequest.Manager__c)){
                return;
            }
            
            if(manager.ManagerType__c == UtilsConstants.MANAGER_TYPE_B2C_SHOWROOM_MANAGER)
            {
                orderCancellationRequest.Manager__c = manager.Id;
                break;
            }
        }
    }

    protected Boolean isDivisionManagerExists(){
        return !String.isBlank(cancellationRequest.DivisionManager__c);
    }

    protected void setDivisionManagerCommon(List<User> managers){
        if(isDivisionManagerExists()) {
            return;
        }
        for(User manager : managers)    
        {
            if(manager.ManagerType__c == UtilsConstants.MANAGER_TYPE_B2C_DIVISION_MANAGER)
            {
                cancellationRequest.DivisionManager__c = manager.Id;
            }
            else
            {
                divisionManagerIdIfNotFound = manager.Id;
            }
        }
    }

    public void setManager(List<User> managers){
        for(User manager : managers){

            if(manager.ManagerType__c == UtilsConstants.MANAGER_TYPE_B2C_DIVISION_MANAGER)
            {
                orderCancellationRequest.DivisionManager__c = manager.Id;
            }
            else
            {
                divisionManagerIdIfNotFound = manager.Id;
            }
        }
    }

    public override void validate(){
        if(cancellationRequest.RegionalManager__c == null || String.isBlank(cancellationRequest.RegionalManager__c)){
            cancellationRequest.addError(Label.RegionalManagerNotFoundForOrder);
        }
        super.validate();
   }

    
    
}
