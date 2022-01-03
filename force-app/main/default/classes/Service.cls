public with sharing class Service implements IService {

	public class ServiceException extends Exception {}

	@TestVisible
	private static IService serviceInstance;

	public interface IService {
		void processAccounts(Id prospectAccountId, Id individualAccountId);
		void updateAccountToClientAndSendEmail(Account prospectAccount);
		void retrieveInformationFromExternalSystem();
		void caseUpdateRouting(Case businessCase);
		void updateCaseDescriptionWithAccountOwnerName(Case businessCase);
	}

	public static IService getInstance() {
		if (serviceInstance == null) {
			serviceInstance = new Service();
		}
		return serviceInstance;
	}

	public void updateAccountToClientAndSendEmail(Account prospectAccount) {
		prospectAccount.Type = 'Client';
		Accounts.getInstance().updateAccountAndSendEmail(prospectAccount);
	}

	public void processAccounts(Id prospectAccountId, Id individualAccountId) {
		Set<Id> idSet = new Set<Id>{prospectAccountId, individualAccountId};
		Map<Id, Account> accountsByIds = new Map<Id, Account>(AccountsSelector.getInstance().getByIds(idSet));

		Account prospectAccount = accountsByIds.get(prospectAccountId);
		if (prospectAccount.Type == 'Client') {
			ExternalSystemConnector.getInstance().callToExternalSystem();
		}

		Account individualAccount = accountsByIds.get(individualAccountId);
		if (individualAccount.Type == 'Private') {
			Accounts.getInstance().updateIndividualDocuments(individualAccount);
		}
	}

	public void retrieveInformationFromExternalSystem() {
		try {
			ExternalSystemConnector.getInstance().callToExternalSystem();
		} catch (ServiceException exc) {
			LogService.getInstance().log('ServiceException: ' + exc.getMessage());
		} catch (Exception exc) {
			LogService.getInstance().log('Exception: ' + exc.getMessage());
		}
	}

	public void caseUpdateRouting(Case businessCase) {
		if (businessCase.Account.Type == 'Client') {
			Cases.getInstance().updateCaseForClient(businessCase);
		} else if (businessCase.Account.Type == 'Prospect') {
			Cases.getInstance().updateCaseForProspect(businessCase);
		}
	}

	public void updateCaseDescriptionWithAccountOwnerName(Case businessCase) {
		businessCase.Description = 'Account owner is ' + businessCase.Account_Owner_Name__c;
		Cases.getInstance().updateCase(businessCase);
	}

}