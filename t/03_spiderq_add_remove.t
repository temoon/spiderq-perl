#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags :add );
use String::Random qw( random_string );


plan('tests' => 10);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 10);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'add');
    can_ok($sq, 'remove');
    
    my $key = random_string('00000000', [ 'a' .. 'z', '0' .. '9', '_' ]);
    my $value = 'value';
    
    $sq->remove($key);
    
    my $flag = $sq->add($key, $value, $SQ_ADD_HEAD);
    
    isnt($flag, undef, "Add('$key', '$value', $SQ_ADD_HEAD): success");
    is($flag, $SQ_ADDED, "Add('$key', '$value', $SQ_ADD_HEAD) -> Added()");
    
    $flag = $sq->add($key, $value, $SQ_ADD_TAIL);
    
    isnt($flag, undef, "Add('$key', '$value', $SQ_ADD_TAIL): success");
    is($flag, $SQ_KEPT, "Add('$key', '$value', $SQ_ADD_TAIL) -> Kept()");
    
    $flag = $sq->remove($key);
    
    isnt($flag, undef, "Remove('$key'): success");
    is($flag, $SQ_REMOVED, "Remove('$key') -> Removed()");
    
    $flag = $sq->remove($key);
    
    isnt($flag, undef, "Remove('$key'): success");
    is($flag, $SQ_NOT_REMOVED, "Remove('$key') -> NotRemoved()");
};

done_testing();


__END__