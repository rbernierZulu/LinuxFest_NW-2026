#!/bin/bash
#
# INVOCATION: Example 02, administering a Hypertable
#
#   ./go-ex02.sh
#
set -e

dropdb --if-exists ex02
createdb ex02

time \
psql ex02 <<_eof_
    create extension timescaledb;

    create table t_timescale(
    id uuid
    ,c2 int default random()*1E6
    ,c3 int default random()*1E6
    ,c4 int default random()*1E6
    ,c5 int default random()*1E6
    ,c6 int default random()*1E6
    ,c7 int default random()*1E6
    ,t_stamp timestamptz not null default clock_timestamp()
    );

    select create_hypertable('t_timescale', 't_stamp');
    select * from set_chunk_time_interval('t_timescale',interval '1 minutes');

    insert into t_timescale(id) select gen_random_uuid() from generate_series(1,5E7);
_eof_
