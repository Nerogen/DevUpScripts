#!/usr/bin/env bash

# ssh connect and package update
ssh -i ./key.pem ubuntu@10.0.2.33 'sudo apt update'