# Control for resource security

## Types

* Prevent
* Detect
* Remediate

## Scenarios flow

1. AZ POLICY DENY possible, REMEDIATE via Az Policy DEPLOYIFNOTEXIST possible, DETECT to make sure
2. AZ POLICY DENY NOT possible, REMEDIATE via Az Policy DEPLOYIFNOTEXIST possible
3. AZ POLICY DENY NOT possible, REMEDIATE via Az Policy DEPLOYIFNOTEXIST NOT possible, DETECT and PAGE ONCALL

## Scenarios flow2

1. PREVENT: AZ POLICY Deny
2. REMEDIATE: AZ POLICY DeployIfNotExists
3. DETECT:
   1. OPTION A (DETECT + REMEDIATE): ALERT > ACTION GROUP > REMEDIATE via Automation runbook
      1. if error: notify
      2. if remediated: notify
   2. OPTION B (DETECT): ALERT > ACTION GROUP > DETECT via Automation runbook
      1. if error: notify
      2. if detect: notify
5. DESTROY Resources ?
   1. if danger of exposure


### notes

* for DeployIfNotExists, in all cases, if existence condition is wrong, it will keep deploying
* in all cases, what if remediation does not work ? how to notify
    DETECT
        check when the resource was changes ? see example `detect_resourcegraph_changes.ps1`


# STEP1: Azure policy DENY (if possible)
# STEP2: REMEDIATION or DETECT If more input is needed
## REMEDIATION via Az Policy DeployIfNotExists
### Option 1
1. azure policy deployifnotexists
    - definition
    - assignment
    - role assignment on msi
#### Result
- this fix new resources within 20min
- existing resources need to be fixed by invoking Remediation task on a scope

### Option 2
1. azure policy deployifnotexists
    - definition
    - assignment
    - role assignment on msi
2. alert + action group + webhook + runbook
    Start-Remediation on ResouceID
#### Result
- this fix resources within 15min
    Alert can take up to 5 min
    Remediation task takes ~10min

    if this takes longer, the remediationtask will automatically kick in after detecting the non-compliant resource after ~20min
- existing resources need to be fixed by invoking Remediation task on a scope

#### PROS and Cons, Open Questions
PROS
    rerun by itself after each compliant evaluation
CONS
-more code to maintain
Q
    how do we notify if this fail ?

## REMEDIATION via ALERT + Runbook





