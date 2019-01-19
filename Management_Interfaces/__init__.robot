*** Settings ***
Documentation   Initialization file of feature_x test suites
...             It is for putting suite level setup and teardown keywords
...             And setting the forced tags for all the test cases in  "feature_x" folder and its subfolder
Force Tags        @require=1eut    @eut=GPON-8r2
Suite Setup       management_interface_setup
Resource          ./base.robot


*** Keywords ***
management_interface_setup
    [Documentation]    suite provision for management interface support
    [Tags]       @author=CindyGao
    log    set eut version and release
    set_eut_version
