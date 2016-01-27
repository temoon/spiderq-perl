#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags );


plan('tests' => 5);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 5);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'count');
    
    my ( $flag, $count ) = $sq->count();
    
    isnt($flag, undef, 'Count(): success');
    is($flag, $SQ_COUNTED, 'Count() -> Counted()');
    
    isnt($count, undef, 'count defined');
    cmp_ok($count, '>=', 0, 'count >= 0');
};

done_testing();


__END__