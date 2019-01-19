*** Settings ***
Documentation   Leo add to let the suite could do some preparation before all test start

#Suite Setup     log to console  >>> feature_x suite setup <<<
#Suite Teardown  log to console  >>> feature_x suite teardown <<<
Force Tags      @require=1eut1ont

Resource          ./base.robot

*** Keywords ***

