#!/usr/bin/env bash

# ssh connect and package update
ssh -i ./key.pem -o StrictHostKeyChecking=no ubuntu@example 'sudo apt update'