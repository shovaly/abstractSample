public with sharing class SetManagerB2B extends SetNonB2CManager {
    
    public SetManagerB2B(SetManagerModel model){
        super(model);
    }

    public override void setManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.B2B_CARGO_MANAGER});
        
        List<String> directManagerRolesB2B = new List<String>{UtilsConstants.B2B_CARGO_MANAGER,
            UtilsConstants.B2B_DISTRIBUTION_SALES_MANAGER_NORTH,
            UtilsConstants.B2B_DISTRIBUTION_SALES_MANAGER_SOUTH,
            UtilsConstants.B2B_INFRASTRUCTURE_SALES_MANAGER,
            UtilsConstants.B2B_STRATEGIC_SALES_MANAGER};
            
            setManagerCommon(directManagerRolesB2B);
        
    }

    public override void setDivisionManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.B2B_CARGO_MANAGER});     
        setDivisionManagerCommon(managers,UtilsConstants.B2B_CARGO_MANAGER,UtilsConstants.MANAGER_TYPE_B2B_DIVISION_MANAGER);
    }

   
}
