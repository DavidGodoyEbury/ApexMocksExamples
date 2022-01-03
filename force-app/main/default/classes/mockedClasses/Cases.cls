public with sharing class Cases implements ICases {

	@TestVisible
	private static ICases domainInstance;

	public interface ICases {
		void updateCase(Case businessCase);
		void updateCaseForClient(Case businessCase);
		void updateCaseForProspect(Case businessCase);
	}

	public static ICases getInstance() {
		if (domainInstance == null) {
			domainInstance = new Cases();
		}
		return domainInstance;
	}

	// As this class will not be instantiated and will be replaced by a mock, there is no need to implement any logic here
	public void updateCase(Case businessCase) {
	}

	public void updateCaseForClient(Case businessCase) {
	}

	public void updateCaseForProspect(Case businessCase) {
	}

}