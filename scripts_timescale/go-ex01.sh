#!/bin/bash
#
# INVOCATION: Example 01, create and populate a Hypertable
#             sudo as postgres
#
#   ./go-ex01.sh
#
set -e

dropdb --if-exists ex01
createdb ex01

psql -q ex01 <<_eof_
   \set ON_ERROR_STOP on
    create extension timescaledb;
    create sequence increment_seq as bigint increment by 7200;
    create table t1 (
        id bigserial,
        t_stamp timestamp with time zone not null default now(),
        payload text
    );

    -- create the hyper table
    select * from create_hypertable('t1', 't_stamp');
_eof_

time \
for u in $(seq 1 1e3)
do
    PAYLOAD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 1024000; echo)

    psql -q ex01 <<_eof_
        insert into t1(t_stamp,payload)
        select  nextval('increment_seq')::text::interval+now(),
               '$PAYLOAD';
_eof_
done


