#include "ProjectApp.h"
#include "project_x/Platform.h"
#include "project_x/Version.h"
#include "project_x/Clock.h"

#include "Poco/Util/HelpFormatter.h"

#include <iostream>

namespace ProjectY {

const auto APPLICATION_NAME = "Project Application";

ProjectApp::ProjectApp() {
}

ProjectApp::~ProjectApp() {

}

const char *ProjectApp::name() const {
	return ProjectY::APPLICATION_NAME;
}

void ProjectApp::defineOptions(Poco::Util::OptionSet &options) {
	// Define default options
	Poco::Util::Application::defineOptions(options);

	options.addOption(
			Poco::Util::Option("help", "h", "Display help information")
					.required(false)
					.repeatable(false)
					.binding("help")
					.callback(Poco::Util::OptionCallback<ProjectApp>(this, &ProjectApp::handleHelp)));

	options.addOption(
			Poco::Util::Option("version", "v", "Display version information")
					.required(false)
					.repeatable(false)
					.callback(Poco::Util::OptionCallback<ProjectApp>(this, &ProjectApp::handleVersion)));
}

void ProjectApp::handleHelp(const std::string &, const std::string &) {
	_infoRequested = true;
	displayHelp();
	stopOptionsProcessing();
}

void ProjectApp::displayHelp() const {
	Poco::Util::HelpFormatter helpFormatter(options());
	helpFormatter.setCommand(commandName());
	helpFormatter.setUsage("OPTIONS");
	helpFormatter.setHeader(
			Poco::format("%s (version: %s)",
						 ProjectY::APPLICATION_NAME,
						 std::string(CMAKE_PROJECT_VERSION))
	);
	helpFormatter.format(std::cout);
}

void ProjectApp::handleVersion(const std::string &, const std::string &) {
	_infoRequested = true;
	displayVersion();
	stopOptionsProcessing();
}

void ProjectApp::displayVersion() const {
	std::cout << Poco::format("%s (version: %s)",
							  ProjectY::APPLICATION_NAME,
							  std::string(CMAKE_PROJECT_VERSION)) << std::endl;

}

void ProjectApp::initialize(Poco::Util::Application &self) {
	if(!_infoRequested) {
		Poco::Util::Application::initialize(self);
		logger().information("Starting up");
	}
}

void ProjectApp::uninitialize() {
	if (!_infoRequested) {
		logger().information("Shutting down");
		Poco::Util::Application::uninitialize();
	}
}

int ProjectApp::main(const std::vector<std::string> &) {
	int result = Poco::Util::Application::EXIT_OK;
	if (!_infoRequested) {

		for(int i=0;i<10;i++)
		{
			std::cout << "Running application" << std::endl;
			ProjectX::Clock::sleep(1000);
		}
		std::cout << std::flush;
	}
	return result;
}

}
