@IsTest
private class ServiceTest {

	/**
	 * @description Simple mocked test using expected values for the verification of results.
	 **/
	@IsTest
	private static void updateAccountToClientAndSendEmail_accountInput_domainLayerInvoked() {

		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		Accounts.IAccounts accountsInstanceMock = (Accounts.IAccounts) mocks.mock(Accounts.class);
		Accounts.domainInstance = accountsInstanceMock;

		// When
		Test.startTest();
		Service.getInstance().updateAccountToClientAndSendEmail(new Account());
		Test.stopTest();

		// Then
		Account expectedAccount = new Account(Type = 'Client');
		((Accounts) mocks.verify(accountsInstanceMock, 1)).updateAccountAndSendEmail(expectedAccount);

	}

	/**
	 * @description Test to demonstrate about mocking stubbing and verification, using spies to control the calls to the mocked classes.
	 **/
	@IsTest
	private static void processAccounts_accountIds_connectorAndDomainInvoked() {

		// Given
		// Generate Ids on runtime to avoid calls to the database to generate new Ids
		Id prospectAccountId = fflib_IDGenerator.generate(Account.SObjectType);
		Id individualAccountId = fflib_IDGenerator.generate(Account.SObjectType);

		// Account records are created on runtime but not inserted, those records will be used for stubbing and verification
		Account prospectAccount = new Account(Id = prospectAccountId, Type = 'Client');
		Account individualAccount = new Account(Id = individualAccountId, Type = 'Private');
		List<Account> accountList = new List<Account>{prospectAccount, individualAccount};

		// Mock all invoked classes
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		AccountsSelector.IAccountsSelector accountsSelectorMock = (AccountsSelector.IAccountsSelector) mocks.mock(AccountsSelector.class);
		AccountsSelector.selectorInstance = accountsSelectorMock;

		ExternalSystemConnector.IExternalSystemConnector connectorInstanceMock = (ExternalSystemConnector.IExternalSystemConnector) mocks.mock(ExternalSystemConnector.class);
		ExternalSystemConnector.connectorInstance = connectorInstanceMock;

		Accounts.IAccounts accountsInstanceMock = (Accounts.IAccounts) mocks.mock(Accounts.class);
		Accounts.domainInstance = accountsInstanceMock;

		mocks.startStubbing();
		mocks.when(accountsSelectorMock.getByIds((Set<Id>) fflib_Match.anyObject())).thenReturn(accountList);
		mocks.stopStubbing();

		// When
		Test.startTest();
		Service.getInstance().processAccounts(prospectAccountId, individualAccountId);
		Test.stopTest();

		// Then
		((ExternalSystemConnector) mocks.verify(connectorInstanceMock, 1)).callToExternalSystem();
		// On the verification of updateIndividualDocuments we have added a spy for individualAccount as that is
		// the specific account we expect to be passed to the Domain layer
		((Accounts) mocks.verify(accountsInstanceMock, 1)).updateIndividualDocuments(individualAccount);

	}

	/**
	 * @description Demonstration of a test which mocks an exception thrown, this scenario is useful to test try-catch blocks without
	 * us trying to exploit our own code to increase code coverage
	 **/
	@IsTest
	private static void retrieveInformationFromExternalSystem_serviceExceptionThrown_logServiceInvoked() {

		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		ExternalSystemConnector.IExternalSystemConnector connectorInstanceMock = (ExternalSystemConnector.IExternalSystemConnector) mocks.mock(ExternalSystemConnector.class);
		ExternalSystemConnector.connectorInstance = connectorInstanceMock;

		LogService.ILogService logServiceMock = (LogService.ILogService) mocks.mock(LogService.class);
		LogService.logInstance = logServiceMock;

		String exceptionMessage = 'Exception message test';
		mocks.startStubbing();
		((ExternalSystemConnector.IExternalSystemConnector) mocks.doThrowWhen(new Service.ServiceException(exceptionMessage), connectorInstanceMock)).callToExternalSystem();
		mocks.stopStubbing();

		// When
		Test.startTest();
		Service.getInstance().retrieveInformationFromExternalSystem();
		Test.stopTest();

		// Then
		((LogService) mocks.verify(logServiceMock, 1)).log('ServiceException: ' + exceptionMessage);

	}


	/**
	 * @description Demonstration of a test which mocks an exception thrown, in order for our test to enter in the generic Exception catch,
	 * we create a new Exception type which is guaranteed not to be used in our business logic code, in this case a newException type in our test classes
	 **/
	private class TestException extends Exception {}

	@IsTest
	private static void retrieveInformationFromExternalSystem_exceptionThrown_logServiceInvoked() {

		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();

		ExternalSystemConnector.IExternalSystemConnector connectorInstanceMock = (ExternalSystemConnector.IExternalSystemConnector) mocks.mock(ExternalSystemConnector.class);
		ExternalSystemConnector.connectorInstance = connectorInstanceMock;

		LogService.ILogService logServiceMock = (LogService.ILogService) mocks.mock(LogService.class);
		LogService.logInstance = logServiceMock;

		String exceptionMessage = 'Exception message test';
		mocks.startStubbing();
		((ExternalSystemConnector.IExternalSystemConnector) mocks.doThrowWhen(new TestException(exceptionMessage), connectorInstanceMock)).callToExternalSystem();
		mocks.stopStubbing();

		// When
		Test.startTest();
		Service.getInstance().retrieveInformationFromExternalSystem();
		Test.stopTest();

		// Then
		((LogService) mocks.verify(logServiceMock, 1)).log('Exception: ' + exceptionMessage);

	}

	/**
	 * @description Test building more complex object structures (Lookups)
	 **/
	@IsTest
	private static void caseUpdateRouting_clientAndProspectCases_casesRouted() {

		// Given
		Account clientAccount = new Account(Type = 'Client');
		Account prospectAccount = new Account(Type = 'Prospect');

		// Apex objects for Account SObject are created and assigned to the Case Account variable, which is a lookup in the Salesforce data model
		Case clientCase = new Case(Account = clientAccount);
		Case prospectCase = new Case(Account = prospectAccount);

		fflib_ApexMocks mocks = new fflib_ApexMocks();

		Cases.ICases casesInstanceMock = (Cases.ICases) mocks.mock(Cases.class);
		Cases.domainInstance = casesInstanceMock;

		// When
		Test.startTest();
		Service.getInstance().caseUpdateRouting(clientCase);
		Service.getInstance().caseUpdateRouting(prospectCase);
		Test.stopTest();

		// Then
		((Cases) mocks.verify(casesInstanceMock, 1)).updateCaseForClient(clientCase);
		((Cases) mocks.verify(casesInstanceMock, 1)).updateCaseForProspect(prospectCase);

	}

	/**
	 * @description Edge case for tests which need records with formula fields generated
	 **/
	@IsTest
	private static void updateCaseDescriptionWithAccountOwnerName_businessCase_domainLayerInvoked() {

		// Given
		// The following commented code would return a failure "The Account_Owner_Name__c field is un-writable"
		// Case businessCaseFailure = new Case();
		// businessCaseFailure.Account_Owner_Name__c = 'Han Solo';

		// We are using a Hacky mechanism to generate a record with a formula field pre-generated, avoiding the "The XX field is un-writable" error when we try to assign a
		// value to a formula field in Apex. In this case we are generating the object in the JSON format with the formula value added to it, and then deserializing the JSON
		String ownerName = 'Han Solo';
		String businessCaseInJsonFormat = '{"Account_Owner_Name__c": "' + ownerName + '"}';
		Case businessCase = (Case) JSON.deserialize(businessCaseInJsonFormat, Case.class);

		fflib_ApexMocks mocks = new fflib_ApexMocks();

		Cases.ICases casesInstanceMock = (Cases.ICases) mocks.mock(Cases.class);
		Cases.domainInstance = casesInstanceMock;

		// When
		Test.startTest();
		Service.getInstance().updateCaseDescriptionWithAccountOwnerName(businessCase);
		Test.stopTest();

		// Then
		Case expectedCase = (Case) JSON.deserialize(businessCaseInJsonFormat, Case.class);
		expectedCase.Description = 'Account owner is ' + ownerName;

		((Cases) mocks.verify(casesInstanceMock, 1)).updateCase(expectedCase);

	}

}