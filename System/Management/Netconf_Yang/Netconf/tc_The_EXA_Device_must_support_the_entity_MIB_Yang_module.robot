  
*** Settings ***
Documentation     The AXOS device MUST support the entity MIB Yang module.
...    The specific required fields are as follows:
...    entPhysicalIndex
...    entPhysicalDescr
...    entPhysicalContainedIn
...    entPhysicalClass
...    entPhysicalParentRelPos
...    entPhysicalName
...    entPhysicalMfgName
...    entPhysicalModelName
...    entPhysicalIsFRU
...    The exact details of the entities is described in other SRs.
...    
...    It is not a requirement that other lists and containers from the entity mib be supported. The primary objective of this requirement is to allow the inventory to be discovered on the Netconf interface.
Force Tags     @feature=Management    @subFeature=Netconf/Yang    @author=cindy gao    @author=gpalanis
Resource          ./base.robot


*** Variables ***
${get_entityPhysical}     <rpc xmlns="urn:ietf:params:xml:ns:netconf:base:1.0" message-id="1"><get xmlns="urn:ietf:params:xml:ns:netconf:base:1.0"><filter type="xpath" select="/status/system/entityPhysical"/></get></rpc>

@{list}    entPhysicalIndex    entPhysicalDescr    entPhysicalContainedIn    entPhysicalClass    entPhysicalParentRelPos    entPhysicalName    entPhysicalMfgName    entPhysicalModelName    entPhysicalIsFRU

*** Test Cases ***
tc_The_E3_2_must_support_the_entity_MIB_Yang_module
    [Documentation]    E3_2 must support the entity MIB Yang module    
    [Tags]       @TCID=AXOS_E72_PARENT-TC-1774        @globalid=2322305

    #Getting physical entity
    ${getPhysicalEntity}=    Netconf Raw    n1_session3    xml=${get_entityPhysical}
    Should Contain    ${getPhysicalEntity.xml}    Calix
    Log    ${getPhysicalEntity}

    #Verify the physical element list is available
    ${physicalElem_msgs}=    Netconf Raw    n1_session3    xml=${get_entityPhysical}
    log     ${physicalElem_msgs}
    : FOR    ${value}    IN    @{list}
    \    Should Contain    ${physicalElem_msgs.xml}    ${value}

