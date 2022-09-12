#!/bin/sh
_cur=$PWD
rm -f "$_cur/member.dat" 
rm -f "$_cur/loan.dat"
rm -f "$_cur/memberfinance.dat"
rm -f "$_cur/address.dat"

python parser.py $_cur/json/*.json