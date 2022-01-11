/**
 * @description       : Order Cancellation Request Trigger Helper
 * @author            : Raz.i
 * @last modified on  : 19/07/2021
 * @last modified by  : Raz.i
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   21/07/2020   Raz.i    CSP-1336
**/
public with sharing class OrderCancellationRequestTriggerHelper 
{   
    /**
    * @ Validate no open liens
    * User Story - CSP-1336
    * @author Raz.i | 17/08/2020 
    * @param List<OrderCancellationRequest__c> orderCancellationRequests 
    **/
    public static void validateNoOpenLiens(List<OrderCancellationRequest__c> orderCancellationRequests)
    {
        List<Id> orderCancellationRequestsOrderNumbers = new List<Id>();

        // Get the related liens
        for (OrderCancellationRequest__c orderCancellationRequest : orderCancellationRequests){
            orderCancellationRequestsOrderNumbers.add(orderCancellationRequest.OrderItem__c);
        }

        List<Lien__c> liensRelated = [SELECT OrderItem__c,LienStatus__c FROM Lien__c WHERE OrderItem__c IN :orderCancellationRequestsOrderNumbers];

        // For each cancellation request
        for (OrderCancellationRequest__c orderCancellationRequest : orderCancellationRequests) 
        {   

            // Only check for transfer balance to order
            if(orderCancellationRequest.TypeOfCredit__c == UtilsConstants.ORDERCANCELLATION_TYPE_OF_CREDIT_TRANSFER_TO_ORDER)
            {

                // If there is a lien open for this order show error 
                for(Lien__c lien : liensRelated)
                {
                    if(lien.OrderItem__c  == orderCancellationRequest.OrderItem__c                 &&
                    lien.LienStatus__c != UtilsConstants.LIEN_STATUS_ABORT_LIEN_APPROVED_BY_SUPPLIER &&
                    lien.LienStatus__c != UtilsConstants.LIEN_STATUS_NOT_APPROVED)
                    {
                        orderCancellationRequest.addError(Label.YouCantCreateOrderCancellationWhenThereIsanOpenLienRelated);
                    }
                } 
            }
        }
    }

    /**
    * @ Validate no open order cancellation exists
    * User Story - CSP-1336
    * @author Raz.i | 23/08/2020 
    * @param List<OrderCancellationRequest__c> orderCancellationRequests 
    **/
    public static void validateNoCancellationExists(List<OrderCancellationRequest__c> orderCancellationRequests)
    {
        List<Id> orderCancellationRequestsOrderNumbers = new List<Id>();

        // Get the existing cancellation requests
        for (OrderCancellationRequest__c orderCancellationRequest : orderCancellationRequests){
            orderCancellationRequestsOrderNumbers.add(orderCancellationRequest.OrderItem__c);
        }

        List<OrderCancellationRequest__c> orderCancellationRequestsExists = [SELECT Id,OrderItem__c, ApprovalStatus__c FROM OrderCancellationRequest__c WHERE OrderItem__c IN :orderCancellationRequestsOrderNumbers];

        // For each cancellation request
        for (OrderCancellationRequest__c orderCancellationRequest : orderCancellationRequests) 
        {   

            // If there is a order cancellation request open for this order show error 
            for(OrderCancellationRequest__c orderCancellationRequestExists : orderCancellationRequestsExists)
            {
                if(orderCancellationRequest.Id                      != orderCancellationRequestExists.Id                && 
                   orderCancellationRequest.OrderItem__c       == orderCancellationRequestExists.OrderItem__c &&
                   orderCancellationRequestExists.ApprovalStatus__c != UtilsConstants.ORDERCANCELLATION_STATUS_REJECTED &&
                   orderCancellationRequestExists.ApprovalStatus__c != UtilsConstants.ORDERCANCELLATION_STATUS_CANCELED)
                {
                    orderCancellationRequest.addError(Label.OrderCancellationRequestAlreadyExists);
                }
            }
            
        }
    }

    /**
    * @ Calculate managers and show error if doesnt exists
    * User Story - CSP-1343
    * @author Raz.i | 24/12/2020
    * @param List<OrderCancellationRequest__c> orderCancellationRequests 
    **/
    public static void calculateManagers(List<OrderCancellationRequest__c> orderCancellationRequests)
    {

        List<Id> orderItemsIds     = new List<Id>();

        // Build order items id for query
        for (OrderCancellationRequest__c orderCancellationRequest : orderCancellationRequests)
        {
            orderItemsIds.add(orderCancellationRequest.OrderItem__c);
        }

        List<OrderItem__c> orderItems = [SELECT Area__c,SalesProcess__r.Division__c,SalesOffice__r.RoleNameManager__c,Config__r.Opportunity__r.RecordType.DeveloperName,Owner.UserRole.DeveloperName,Owner.UserRole.ParentRoleId FROM OrderItem__c WHERE Id IN :orderItemsIds];
        Map<Id,OrderItem__c> orderItemsMap = new Map<Id,OrderItem__c>(orderItems);

        List<String> managersRoles = new List<String>();

        // Build roles names for query
        for (OrderItem__c orderItem : orderItems)
        {
            managersRoles.add(orderItem.SalesOffice__r.RoleNameManager__c);
        }

        managersRoles.add(UtilsConstants.HYUNDAI_DIVISION_MANAGER);
        managersRoles.add(UtilsConstants.MITSUBISHI_DIVISION_MANAGER);
        managersRoles.add(UtilsConstants.B2B_CARGO_MANAGER);
        managersRoles.add(UtilsConstants.TRANSPORT_DIVISION_MANAGER);

        // Query for direct and division managers
        List<User> managers = [SELECT Id,UserRole.DeveloperName,ManagerType__c FROM User 
                                                                              WHERE UserRole.DeveloperName IN :managersRoles
                                                                                AND IsActive = true
                                                                           ORDER BY ManagerType__c DESC NULLS LAST];



        // For each cancellation request
        for (OrderCancellationRequest__c orderCancellationRequest : orderCancellationRequests) 
        {   
           
            // Get current order item
            OrderItem__c currentOrderItem = orderItemsMap.get(orderCancellationRequest.OrderItem__c);
            SetManagerModel model = new SetManagerModel();
            
            model.currentOrderItem = currentOrderItem;
            model.managers = managers;
            model.cancellationRequest = orderCancellationRequest;
            

            ISetManager setManagerfactory = Factory.getSetManagerFactory(model);
            setManagerfactory.setManager();
            setManagerfactory.setDivisionManager();
            setManagerfactory.validate();
        }
    }

    private static Id getDirectManagerByHierarchy(List<String> directManagerRoles, OrderItem__c currentOrderItem)
    {
        Id directManagerId;
        String currentOrderItemRole         = currentOrderItem.Owner.UserRole.DeveloperName;
        String currentOrderItemParentRoleId = currentOrderItem.Owner.UserRole.ParentRoleId;

        // Direct Manager, Check if current user is manager
        if(directManagerRoles.contains(currentOrderItemRole))
        {
            directManagerId =  UserInfo.getUserId();
        }
        else
        {
            Boolean parentExists = true;

            // Go up the hierarchy until we reach direct manager - by role
            while ((directManagerId == null || String.isBlank(directManagerId)) && parentExists) 
            {
                List<User> parentUser = new List<User>();
                if(String.isNotBlank(currentOrderItemParentRoleId))
                {

                    // Get parent users
                    parentUser = [SELECT Id,UserRole.ParentRoleId,UserRole.DeveloperName FROM User WHERE UserRole.Id = :currentOrderItemParentRoleId 
                                                                                                        AND IsActive = true
                                                                                                ORDER BY ManagerType__c DESC NULLS LAST];
                }
                if(parentUser.isEmpty())
                {
                    parentExists = false;
                    break;
                }
                else if(directManagerRoles.contains(parentUser[0].UserRole.DeveloperName))
                {
                    directManagerId = parentUser[0].Id;
                    break;
                }
                
                // Set current user as parent
                currentOrderItemParentRoleId = parentUser[0].UserRole.ParentRoleId;
            }
        }

        return directManagerId;
    }

    private static Id getManagerByRoleAndType(List<User> managers, String roleName,String managerType)
    {
        Id managerIdIfNotFound;

        for(User manager : managers)
        {
            if(manager.UserRole.DeveloperName == roleName)
            {
                if(manager.ManagerType__c == managerType)
                {
                    return manager.Id;
                }
                else
                {
                    managerIdIfNotFound = manager.Id;
                }
            }
        }

        return managerIdIfNotFound;
    }
}