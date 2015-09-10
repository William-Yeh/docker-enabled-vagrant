#!/bin/bash


cp -r bento/floppy    ubuntu-trusty
cp -r bento/http      ubuntu-trusty
cp -r bento/scripts   ubuntu-trusty

cp -r bento/floppy    debian-jessie
cp -r bento/http      debian-jessie
cp -r bento/scripts   debian-jessie

cp -r bento/floppy    centos7
cp -r bento/http      centos7
cp -r bento/scripts   centos7

cp -r bento/floppy    insecure-registry
cp -r bento/http      insecure-registry
cp -r bento/scripts   insecure-registry
