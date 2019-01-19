*** Settings ***
Suite Setup       snmp_admin
Suite Teardown    snmp_admin_disable
Force Tags        @eut=NGPON2-4    @require=1eut   @eut=GPON-8r2
Resource          ./base.robot

*** Variables ***

*** Keywords ***
snmp_admin
    [Tags]    @author=Sewang
    cli    eutA    config
    cli    eutA    snmp
    cli    eutA    v2 community public ro
    cli    eutA    v2 trap-host 192.168.1.1 public
    cli    eutA    end

snmp_admin_disable
    [Tags]    @author=Sewang
    cli    eutA    config
    cli    eutA    snmp
    cli    eutA    no v2 community public ro
    cli    eutA    no v2 trap-host 192.168.1.1 public
    Axos Cli With Error Check   eutA    v2 admin-state disable
    cli    eutA    end
