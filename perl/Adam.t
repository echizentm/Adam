#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok('Adam') };

test_01();
test_02();
test_03();

sub test_01 {
    note('check new()');

    my $classifier = Adam->new();
    ok($classifier, 'new()');
}

sub test_02 {
    note('check update()');

    my $classifier = Adam->new();

    is($classifier->update(), undef, 'update() with no params');

    is($classifier->update(
        data  => {'a' => 1 },
        label => 0,
    ), undef, 'update() with label is not in {1, -1}');

    ok($classifier->update(
        data  => {'a' => 1 },
        label => 1,
    ), 'update() with positive data');

    ok($classifier->update(
        data  => {'a' => 1 },
        label => -1,
    ), 'update() with negative data');
}

sub test_03 {
    note('check classify()');

    my $classifier = Adam->new();
    $classifier->update(
        data  => {'a' => 1 },
        label => 1,
    );
    $classifier->update(
        data  => {'b' => 1 },
        label => -1,
    );

    is($classifier->classify(), undef, 'classify() with no params');

    is($classifier->classify(
        data => {'a' => 1 },
    ), 1, 'classify() with positive data');

    is($classifier->classify(
        data => {'b' => 1 },
    ), -1, 'classify() with negative data');
}

done_testing();
