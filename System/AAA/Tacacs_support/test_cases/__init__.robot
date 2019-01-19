*** Settings ***
Suite Setup       provision
Suite Teardown    deprovision
Force Tags        @feature=10GE-12: TACACS+ support 
Resource          ./base.robot

*** Variables ***

*** Keywords ***
provision
    [Documentation]
    [Tags]    @author=Sean Wang
    log    This is just the Keyword template, replace it with your truly keyword.
    Configure    eutA    aaa tacacs server ${tacacs_ip_1} secret ${tacacs_ps}
    Configure    eutA    cli show-defaults enable
    Configure    eutA    cli telnet enable


deprovision
    [Documentation]
    [Tags]    @author=Sean Wang
    log    This is just the Keyword template, replace it with your truly keyword.
    Configure    eutA    no aaa tacacs server ${tacacs_ip_1}
    Configure    eutA    cli show-defaults disable
    Configure    eutA    cli telnet disable