public  with sharing  virtual class Factory {
    

    public static ISetManager getSetManagerFactory(SetManagerModel model) {

        if(isHyunday(orderItem)) {
            return new SetManagerB2CHyundai(model);
        }
        if(isMitsubishi(orderItem)){
            return new SetManagerB2CMitsubishi(model);
        }
        if(isB2b(orderItem)){
            return new SetManagerB2C(model);
        }
        return new SetManagerTransport(model);
    }

    

    public static ISetManager getSetManagerFactoryDI(SetManagerModel model) {
        Type scheduledClassType = Type.forName(getConcreteFromMetaData(model.currentOrderItem.Opportunity_RecordType_DevName__c));
        ISetManager scheduledInstance = (ISetManager)scheduledClassType.newInstance();

        if(isHyunday(orderItem)) {
            return new SetManagerB2CHyundai(model);
        }
        if(isMitsubishi(orderItem)){
            return new SetManagerB2CMitsubishi(model);
        }
        if(isB2b(orderItem)){
            return new SetManagerB2C(model);
        }
        return new SetManagerTransport(model);
    }

    private static string getConcreteFromMetaData(string parameter){
        ClassDI__mdt[] roleNamesForTATList = [SELECT ClassName__C FROM ClassDI__mdt WHERE parameter =: parameter];
        return roleNamesForTATList[0].ClassName__C;
    }


    private static Boolean isB2b(OrderItem__c currentOrderItem){
            return currentOrderItem.Config__r.Opportunity__r.RecordType.DeveloperName != UtilsConstants.OPPORTUNITY_HYUNDAI_RT  &&
                   currentOrderItem.Config__r.Opportunity__r.RecordType.DeveloperName != UtilsConstants.OPPORTUNITY_MITSUBISHI_RT;
    }
    private static Boolean isHyunday(OrderItem__c currentOrderItem){
        return currentOrderItem.Config__r.Opportunity__r.RecordType.DeveloperName == UtilsConstants.OPPORTUNITY_HYUNDAI_RT;
    }

    private static Boolean isMitsubishi(OrderItem__c currentOrderItem){
        return currentOrderItem.Config__r.Opportunity__r.RecordType.DeveloperName == UtilsConstants.OPPORTUNITY_MITSUBISHI_RT;
    }

 
}



