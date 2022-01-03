public with sharing class ExternalSystemConnector implements IExternalSystemConnector {

	@TestVisible
	private static IExternalSystemConnector connectorInstance;

	public interface IExternalSystemConnector {
		void callToExternalSystem();
	}

	public static IExternalSystemConnector getInstance() {
		if (connectorInstance == null) {
			connectorInstance = new ExternalSystemConnector();
		}
		return connectorInstance;
	}

	// As this class will not be instantiated and will be replaced by a mock, there is no need to implement any logic here
	public void callToExternalSystem() {
	}

}