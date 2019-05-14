#ifndef PROJECT_Y_PROJECTAPP_H
#define PROJECT_Y_PROJECTAPP_H

#include "Poco/Util/Application.h"

namespace ProjectY {

class ProjectApp : public Poco::Util::Application {
public:
    ProjectApp();
    virtual ~ProjectApp();

    const char *name() const override;

protected:
    void initialize(Application &self) override;

    void uninitialize() override;

    int main(const std::vector<std::string> &args) override;

    void defineOptions(Poco::Util::OptionSet &options) override;

private:
    void handleHelp(const std::string &, const std::string &);
    void displayHelp() const;

    void handleVersion(const std::string &, const std::string &);
    void displayVersion() const;

    bool _infoRequested = { false };
};

}

#endif //PROJECT_Y_PROJECTAPP_H
