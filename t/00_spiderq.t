#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;


plan('tests' => 2);

require_ok('SpiderQ');

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 1);
    }
    
    my $sq = new_ok('SpiderQ', [ 'server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'} ]);
};

done_testing();


__END__