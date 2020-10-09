#!/bin/bash

if [ -f "/mnt/efs-maxio-burst/padding.img" ]
then
	echo "/mnt/efs-maxio-burst/padding.img already exists."
else
	dd if=/dev/zero of=/mnt/efs-maxio-burst/padding.img bs=1G count=98 > efs-maxio-burst-padding.log
fi

if [ -f "/mnt/efs-gp-burst/padding.img" ]
then
	echo "/mnt/efs-gp-burst/padding.img already exists."
else
	dd if=/dev/zero of=/mnt/efs-gp-burst/padding.img bs=1G count=98 > efs-gp-burst-padding.log
fi
