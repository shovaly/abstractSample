public with sharing class SetManagerB2CHyundai extends SetManagerB2C {
    
    public SetManagerB2CHyundai(SetManagerModel model){
        super(model);
    }

    public override void setDivisionManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.HYUNDAI_DIVISION_MANAGER});
        setDivisionManagerCommon(managers);
    }

    public void serManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.HYUNDAI_DIVISION_MANAGER});
        setManagerCommon(managers);
    }
}
