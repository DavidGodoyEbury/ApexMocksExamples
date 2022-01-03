public with sharing class Accounts implements IAccounts {

	@TestVisible
	private static IAccounts domainInstance;

	public interface IAccounts {
		void updateIndividualDocuments(Account account);
		void updateAccountAndSendEmail(Account account);
	}

	public static IAccounts getInstance() {
		if (domainInstance == null) {
			domainInstance = new Accounts();
		}
		return domainInstance;
	}

	// As this class will not be instantiated and will be replaced by a mock, there is no need to implement any logic here
	public void updateIndividualDocuments(Account account) {
	}

	public void updateAccountAndSendEmail(Account account) {
	}

}