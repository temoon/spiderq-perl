#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags );


plan('tests' => 23);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 23);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'stats');
    
    my ( $flag, $ping, $count, $add, $update, $lookup, $remove, $lend, $repay, $heartbeat, $stats ) = $sq->stats();
    
    isnt($flag, undef, 'Stats(): success');
    is($flag, $SQ_STATS_GOT, 'Stats() -> StatsGot()');
    
    isnt($ping, undef, 'ping defined');
    cmp_ok($ping, '>=', 0, 'ping >= 0');
    
    isnt($count, undef, 'count defined');
    cmp_ok($count, '>=', 0, 'count >= 0');
    
    isnt($add, undef, 'add defined');
    cmp_ok($add, '>=', 0, 'add >= 0');
    
    isnt($update, undef, 'update defined');
    cmp_ok($update, '>=', 0, 'update >= 0');
    
    isnt($lookup, undef, 'lookup defined');
    cmp_ok($lookup, '>=', 0, 'lookup >= 0');
    
    isnt($remove, undef, 'remove defined');
    cmp_ok($remove, '>=', 0, 'remove >= 0');
    
    isnt($lend, undef, 'lend defined');
    cmp_ok($lend, '>=', 0, 'lend >= 0');
    
    isnt($repay, undef, 'repay defined');
    cmp_ok($repay, '>=', 0, 'repay >= 0');
    
    isnt($heartbeat, undef, 'heartbeat defined');
    cmp_ok($heartbeat, '>=', 0, 'heartbeat >= 0');
    
    isnt($stats, undef, 'stats defined');
    cmp_ok($stats, '>=', 0, 'stats >= 0');
};

done_testing();


__END__