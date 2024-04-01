#!/bin/bash

sudo docker exec -ti `cat container.id` watch -n 0.5 tc -s qdisc