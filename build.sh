#!/bin/bash

export ANT_OPTS='-Xmx512m -Dinfo.aduna.platform.appdata.basedir=./webapps/openrdf-sesame/app_dir/ -Dorg.eclipse.jetty.LEVEL=WARN'

sw/ant/bin/ant -S -f local.build.xml $*

