public with sharing virtual class SetNonB2CManager extends SetManagerBase {

    public SetNonB2CManager(SetManagerModel model){
        super(model);
    }

    public void setManagerCommon(List<String> roles){
        cancellationRequest.Manager__c = getDirectManagerByHierarchy(roles);
    }

    public void setDivisionManagerCommon(List<User> managers,string roleName,string managerType){
        cancellationRequest.DivisionManager__c = getManagerByRoleAndType(managers,roleName,managerType);
    }

    //private methods
    private Id getManagerByRoleAndType(List<User> managers, String roleName,String managerType)
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

    protected Id getDirectManagerByHierarchy(List<String> roles)
    {
        Id directManagerId;
        
        String currentOrderItemRole         = currentOrderItem.Owner.UserRole.DeveloperName;
        String currentOrderItemParentRoleId = currentOrderItem.Owner.UserRole.ParentRoleId;

        // Direct Manager, Check if current user is manager
        if(roles.contains(currentOrderItemRole))
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
                else if(roles.contains(parentUser[0].UserRole.DeveloperName))
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
}
