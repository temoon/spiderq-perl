#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags );


plan('tests' => 3);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 3);
    }
    
    if ( not $ENV{'SPIDERQ_FLUSH'} ) {
        skip('SPIDERQ_FLUSH is false', 3);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'flush');
    
    my $flag = $sq->flush();
    
    isnt($flag, undef, 'Flush(): success');
    is($flag, $SQ_FLUSHED, 'Flush() -> Flushed()');
};

done_testing();


__END__