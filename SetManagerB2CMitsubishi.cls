public with sharing class SetManagerB2CMitsubishi extends SetManagerB2C {
    
    public SetManagerB2CMitsubishi(SetManagerModel model){
        super(model);
    }

    public override void setDivisionManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.MITSUBISHI_DIVISION_MANAGER});
        setDivisionManagerCommon(managers);
    }

    public void serManager(){
        List<User> managers = getManagers(new List<string>{UtilsConstants.MITSUBISHI_DIVISION_MANAGER});
        setManagerCommon(managers);
    }
}
