#!/bin/sh

rm -rf package source staging log build conf/installed
find image/ -name *.gz -delete
find image/ -name *.iso -delete
