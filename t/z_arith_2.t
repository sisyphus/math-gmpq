
# This file initially provided by Trizen  #

###########################################
# When $rop and $op are the same variable #
###########################################

use strict;
use warnings;

use Math::GMPq;
use Test::More;

eval{require Math::GMPz};

if ($@) {
    warn "\$\@: $@\n";
    plan(skip_all => "Math::GMPz could not be loaded");
}


plan tests => 33;

{
    my $q = Math::GMPq->new('42');
    my $z = Math::GMPz->new('3');
    Math::GMPq::Rmpq_add_z($q, $q, $z);
    is("$q", 45, 'Rmpq_add_z($q, $q, $z)');
}

{
    my $q = Math::GMPq->new('42');
    my $z = Math::GMPz->new('3');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_add_z($r, $q, $z);
    is("$r", 45, 'Rmpq_add_z($r, $q, $z)');
    is("$q", '42');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_add_z($q, $q, $z);
    is("$q", '1205/12', 'Rmpq_add_z($q, $q, $z)');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_add_z($q, $q, $z);
    is("$q", '1195/12', 'Rmpq_add_z($q, $q, $z)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('-100');
    Math::GMPq::Rmpq_add_z($q, $q, $z);
    is("$q", '-1195/12', 'Rmpq_add_z($q, $q, $z)');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('-100');
    Math::GMPq::Rmpq_add_z($q, $q, $z);
    is("$q", '-1205/12', 'Rmpq_add_z($q, $q, $z)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_add_z($r, $q, $z);
    is("$r", '1205/12', 'Rmpq_add_z($r, $q, $z)');
    is("$q", '5/12');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_add_z($r, $q, $z);
    is("$r", '1195/12', 'Rmpq_add_z($r, $q, $z)');
    is("$q", '-5/12');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('-100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_add_z($r, $q, $z);
    is("$r", '-1205/12', 'Rmpq_add_z($r, $q, $z)');
    is("$q", '-5/12');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('-100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_add_z($r, $q, $z);
    is("$r", '-1195/12', 'Rmpq_add_z($r, $q, $z)');
    is("$q", '5/12');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_z_sub($q, $z, $q);
    is("$q", '1195/12', 'Rmpq_z_sub($q, $z, $q)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('-100');
    Math::GMPq::Rmpq_z_sub($q, $z, $q);
    is("$q", '-1205/12', 'Rmpq_z_sub($q, $z, $q)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('-100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_z_sub($r, $z, $q);
    is("$r", '-1205/12', 'Rmpq_z_sub($r, $z, $q)');
    is("$q", '5/12');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('-100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_z_sub($r, $z, $q);
    is("$r", '-1205/12', 'Rmpq_z_sub($r, $z, $q)');
    is("$q", '5/12');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('-100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_z_sub($r, $z, $q);
    is("$r", '-1195/12', 'Rmpq_z_sub($r, $z, $q)');
    is("$q", '-5/12');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_z_sub($r, $z, $q);
    is("$r", '1205/12', 'Rmpq_z_sub($r, $z, $q)');
    is("$q", '-5/12');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_z_sub($q, $z, $q);
    is("$q", '1205/12', 'Rmpq_z_sub($q, $z, $q)');
}

{
    my $q = Math::GMPq->new('-5/12');
    my $z = Math::GMPz->new('-100');
    Math::GMPq::Rmpq_z_sub($q, $z, $q);
    is("$q", '-1195/12', 'Rmpq_z_sub($q, $z, $q)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_sub_z($q, $q, $z);
    is("$q", '-1195/12', 'Rmpq_sub_z($q, $q, $z)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    my $r = Math::GMPq->new('0');
    Math::GMPq::Rmpq_sub_z($r, $q, $z);
    is("$r", '-1195/12', 'Rmpq_sub_z($r, $q, $z)');
    is("$q", '5/12');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_div_z($q, $q, $z);
    is("$q", '1/240', 'Rmpq_div_z($q, $q, $z)');

    Math::GMPq::Rmpq_z_div($q, $z, $q);
    is("$q", '24000', 'Rmpq_z_div($q, $z, $q)');
}

{
    my $q = Math::GMPq->new('5/12');
    my $z = Math::GMPz->new('100');
    Math::GMPq::Rmpq_mul_z($q, $q, $z);
    is("$q", '125/3', 'Rmpq_mul_z($q, $q, $z)');
}
