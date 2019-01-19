*** Settings ***
Documentation     11
Suite Setup       Common_Setup
Suite Teardown    Teardown
Force Tags        @feature=AXOS-WI-395     @require=1eut        @eut=GPON-8r2
Resource          base.robot

*** Keywords ***
Common_Setup
    [Documentation]    Configure Vlan,Transport service,Class map and policy map
    log    *** \ Clean up the config \ ***
    set_eut_version
    get_ntp_config   n3
#    cli    n3   copy config from rolt1_tc_config to startup-config

Teardown
    log    *** \ Clean up the config \ ***
