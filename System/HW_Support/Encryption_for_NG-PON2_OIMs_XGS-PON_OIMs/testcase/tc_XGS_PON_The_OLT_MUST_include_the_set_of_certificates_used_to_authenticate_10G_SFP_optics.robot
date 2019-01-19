*** Settings ***
Documentation     The OLT software MUST include the set of certificates used in the authentication process for 10G SFPs. 
...    These certificates provide a way to distribute the public keys associated with the encryption process used when the SFPs are manufactured. 
...    These certificates should be part of the OLT build, and not require any operator installation on the OLT.
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_XGS_PON_The_OLT_MUST_include_the_set_of_certificates_used_to_authenticate_10G_SFP_optics
    [Documentation]    
    ...    1    Pre Test Criteria - Clear all alarms on the system prior to running this test case. Verify the system is alarm free. "show alarm active".
    ...    2    Plug an XGS_PON SFP into and verify the system is alarm free. "show alarm active".
    ...    3    Verify the PON port can be put into service via the following set of CLI commands. "config"; "interface pon "; "no shutdown" then issue "exit"; "exit" "show interface pon status admin-state" and verfy PON port is in the enabled state.
    ...    4    Create an ONT and connect the ONT to the PON port. Verify the port is in the operational state of "up" using the command "show interface pon status oper-state".
    ...    5    Verify that no "unsupported equipment alarms" are posted on the system. 
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-2997    @globalid=2445903    @eut=NGPON2-4    @priority=p1     @subfeature=Encryption_for_NG-PON2_OIMs_XGS-PON_OIMs 
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:
    log    STEP:1 Pre Test Criteria - Clear all alarms on the system prior to running this test case. Verify the system is alarm free. "show alarm active"
    ${res2}    cli    eutA    show alarm active
    log    STEP:2 Plug an XGS_PON SFP into and verify the system is alarm free. "show alarm active".
    ${res3}    cli    eutA    show alarm active
    log    STEP:3 Verify the PON port can be put into service via the following set of CLI commands. "config"; "interface pon "; "no shutdown" then issue "exit"; "exit" "show interface pon status admin-state" and verfy PON port is in the enabled state.
    ${pon_port}    subscriber_point_get_pon_port_name    subscriber_point1
    ${res}    cli    eutA    show interface pon ${pon_port} status admin-state
    should contain   ${res}    enable       
    log    STEP:4 Create an ONT and connect the ONT to the PON port. Verify the port is in the operational state of "up" using the command "show interface pon status oper-state".
    subscriber_point_check_status_up    subscriber_point1
    log    STEP:5 Verify that no "unsupported equipment alarms" are posted on the system.
    ${res1}    cli    eutA    show alarm active
    should not contain   ${res1}    unsupported equipment alarms
    


*** Keywords ***
case setup
    [Documentation]    case setup
    [Arguments]
    log    case setup   
    subscriber_point_prov    subscriber_point1
case teardown
    [Documentation]    case teardown
    [Arguments]
    log    case teardown
    subscriber_point_dprov    subscriber_point1
    
    
    