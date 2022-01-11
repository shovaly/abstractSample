public interface ISetManager {
    void setManager(); 
    void setDivisionManager();
    List<User> getManagers(List<string> roles);
    void validate();

}
