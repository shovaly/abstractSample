public with sharing class SetManagerModel {
    
    public OrderCancellationRequest__c cancellationRequest {get;set;}
    public OrderItem__c currentOrderItem {get;set;}
    public List<OrderItem__c> orderItems {get;set;}
    public List<User> managers {get;set;}
}
