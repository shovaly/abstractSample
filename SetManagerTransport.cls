public with sharing class SetManagerTransport extends SetNonB2CManager {
    
    public SetManagerTransport(SetManagerModel model){
        super(model);
    }

    public override void setManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.TRANSPORT_DIVISION_MANAGER});
        
        List<String> directManagerRolesTransport = new List<String>{UtilsConstants.TRANSPORT_SALES_MANAGER,
            UtilsConstants.TRANSPORT_SPECIAL_MANAGER};
            
            setManagerCommon(directManagerRolesTransport);
        
    }

    public override void setDivisionManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.TRANSPORT_DIVISION_MANAGER});     
        setDivisionManagerCommon(managers,UtilsConstants.TRANSPORT_DIVISION_MANAGER,UtilsConstants.MANAGER_TYPE_B2B_DIVISION_MANAGER);
    }

   
}
