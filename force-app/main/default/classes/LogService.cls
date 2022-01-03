public with sharing class LogService implements ILogService {
	@TestVisible
	private static ILogService logInstance;

	public interface ILogService {
		void log(String errorMessage);
	}

	public static ILogService getInstance() {
		if (logInstance == null) {
			logInstance = new LogService();
		}
		return logInstance;
	}

	// As this class will not be instantiated and will be replaced by a mock, there is no need to implement any logic here
	public void log(String errorMessage) {
	}

}