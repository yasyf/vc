#!/bin/bash

if [[ -n "$SKIP_RELEASE" ]]; then exit; fi

rake db:migrate