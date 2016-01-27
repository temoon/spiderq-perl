#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags :add :lend );
use String::Random qw( random_string );


plan('tests' => 5);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 5);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'heartbeat');
    
    my $key = random_string('00000000', [ 'a' .. 'z', '0' .. '9', '_' ]);
    my $value = 'value';
    my $heartbeat_timeout = 1_000;
    my $lend_timeout = 1_000;
    
    $sq->remove($key);
    
    my $flag = $sq->heartbeat(0, $key, $heartbeat_timeout);
    
    isnt($flag, undef, "Heartbeat(0, '$key', $heartbeat_timeout): success");
    is($flag, $SQ_SKIPPED, "Heartbeat(0, '$key', $heartbeat_timeout) -> Skipped()");
    
    $sq->add($key, $value, $SQ_ADD_HEAD);
    
    my ( undef, $lend_key, $lent_key, $lent_value ) = $sq->lend($lend_timeout, $SQ_LEND_BLOCK);
    
    $flag = $sq->heartbeat($lend_key, $lent_key, $heartbeat_timeout);
    
    isnt($flag, undef, "Heartbeat($lend_key, '$key', $heartbeat_timeout): success");
    is($flag, $SQ_HEARTBEATEN, "Heartbeat($lend_key, '$lent_key', $heartbeat_timeout) -> Heartbeaten()");
    
    $sq->remove($key);
};

done_testing();


__END__