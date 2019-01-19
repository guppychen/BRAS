*** Settings ***
Documentation     SIP Service help parameters
Resource          ./base.robot


*** Variables ***


*** Test Cases ***
tc_SIP_Service_help_parameters
    [Documentation]    1. Enter a question mark to see the following parameters on SIP service: interface pots 211/p1 sip-service META-SIP
    [Tags]       @author=XUAN LI     @TCID=AXOS_E72_PARENT-TC-3410    @globalid=2473167    @priority=P3    @eut=GPON-8r2     @user_interface=CLI
    [Setup]      case setup
    [Teardown]   case teardown
    log    STEP:1. Enter a question mark to see the following parameters on SIP service: interface pots 211/p1 sip-service META-SIP
    cli    eutA    configure
    ${pots_id1}    subscriber_point_get_interface_pot_name    subscriber_point1    1   
    ${res}    cli    eutA    interface pots ${pots_id1} sip-service ${ua_id} ${question_mark}
    &{param_dict}    create dictionary    call-waiting=Enable/Disable call waiting    caller-id=Enable/Disable caller id    dial-plan=Specify dial-plan
    ...    direct-connect=warm-line/hot-line phone number    direct-connect-timer=warm-line/hot-line timer value in seconds    domain=Domain name    msg-waiting-indicator=Enable/Disable message waiting indicator
    ...    password=password    shutdown=sip service administrative state    t38-fax-relay=Enable/Disable T.38 fax relay    three-way-calling=Enable/Disable 3-way calling
    ...    uri=URI    user=user name
    @{list_key}    Get Dictionary Keys    ${param_dict}     
    : FOR    ${param}    IN    @{list_key}
    \     Should Match Regexp    ${res}    ${param}\\s* - ${param_dict['${param}']}


*** Keywords ***
case setup
    [Documentation]
    [Arguments]
    log    case setup


case teardown
    [Documentation]
    [Arguments]
    log    case teardown

