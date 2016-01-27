#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use strict;
use warnings;

use Test::More;

use SpiderQ qw( :flags :add );
use String::Random qw( random_string );


plan('tests' => 5);

SKIP: {
    if ( not defined $ENV{'SPIDERQ_SERVER'} ) {
        skip('SPIDERQ_SERVER is not set', 5);
    }
    
    my $sq = SpiderQ->new('server' => $ENV{'SPIDERQ_SERVER'}, 'timeout' => $ENV{'SPIDERQ_TIMEOUT'});
    
    can_ok($sq, 'update');
    
    my $key = random_string('00000000', [ 'a' .. 'z', '0' .. '9', '_' ]);
    my $value = 'value';
    my $new_value = 'new value';
    
    $sq->remove($key);
    
    my $flag = $sq->update($key, $new_value);
    
    isnt($flag, undef, "Update('$key', '$new_value'): success");
    is($flag, $SQ_NOT_FOUND, "Update('$key', '$new_value') -> NotFound()");
    
    $sq->add($key, $value, $SQ_ADD_TAIL);
    
    $flag = $sq->update($key, $new_value);
    
    isnt($flag, undef, "Update('$key', '$new_value'): success");
    is($flag, $SQ_UPDATED, "Update('$key', '$new_value') -> Updated()");
    
    $sq->remove($key);
};

done_testing();


__END__