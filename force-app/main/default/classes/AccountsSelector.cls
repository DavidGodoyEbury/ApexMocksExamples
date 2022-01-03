public with sharing class AccountsSelector implements IAccountsSelector {

	@TestVisible
	private static IAccountsSelector selectorInstance;

	public interface IAccountsSelector {
		Account getById(Id accountId);
		List<Account> getByIds(Set<Id> accountId);
	}

	public static IAccountsSelector getInstance() {
		if (selectorInstance == null) {
			selectorInstance = new AccountsSelector();
		}
		return selectorInstance;
	}

	// As this class will not be instantiated and will be replaced by a mock, there is no need to implement any logic here
	public Account getById(Id accountId) {
		return null;
	}

	public List<Account> getByIds(Set<Id> accountId) {
		return null;
	}

}