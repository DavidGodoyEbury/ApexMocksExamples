#!/usr/bin/env bash

sfdx force:org:create -s -f config/project-scratch-def.json orgName=DavidApexMocksST -a DavidApexMocksST -v EburyHub

sfdx force:source:push -f
