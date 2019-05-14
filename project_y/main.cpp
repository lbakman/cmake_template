#include "ProjectApp.h"
#include <iostream>

/*
 * Keep the main declaration out of the source tree of the executable module to avoid having two main declarations in
 * the unit test suite.
 */
POCO_APP_MAIN(ProjectY::ProjectApp)
