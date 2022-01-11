public with sharing abstract class SetManagerBase implements IsetManager { 

    protected OrderItem__c currentOrderItem = null;
    protected OrderCancellationRequest__c cancellationRequest = null;
    protected List<OrderItem__c> orderItems = null;
    protected List<User> managers = null;

   public SetManagerBase(SetManagerModel model){
       this.currentOrderItem = model.currentOrderItem;
       this.cancellationRequest = model.cancellationRequest;
       this.orderItems = model.orderItems;
       this.managers = model.managers;
   }


   public abstract void setManager();
   public abstract void setDivisionManager();

   public List<User> getManagers(List<string> managerTypes){
    // Query for direct and division managers
    List<User> managers = [SELECT Id,UserRole.DeveloperName,ManagerType__c FROM User 
                                                                          WHERE UserRole.DeveloperName In: managerTypes
                                                                            AND IsActive = true
                                                                       ORDER BY ManagerType__c DESC NULLS LAST];
    return managers;
   }

   public virtual void validate(){
        if(cancellationRequest.DivisionManager__c == null || String.isBlank(cancellationRequest.DivisionManager__c))
        {
                cancellationRequest.addError(Label.DivisionManagerNotFoundForOrder);
        }
   }
}
